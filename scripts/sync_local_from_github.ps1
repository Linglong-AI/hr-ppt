# Sync installed hr-ppt skill copies from the GitHub source of truth.
# Normal case: valid Git checkouts are fast-forwarded.
# Repair case: broken or missing folders are backed up and mirrored from a
# temporary GitHub clone.

[CmdletBinding()]
param(
    [string]$RepoUrl = "https://github.com/Linglong-AI/hr-ppt.git",
    [string]$Ref = "main",
    [ValidateSet("all", "codex", "claude")]
    [string]$Target = "all",
    [string]$CodexDest = (Join-Path $HOME ".codex\skills\hr-ppt"),
    [string]$ClaudeDest = (Join-Path $HOME ".claude\skills\hr-ppt"),
    [string]$Dest,
    [string]$WorkDir,
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-FullPath {
    param([Parameter(Mandatory = $true)][string]$Path)
    return [System.IO.Path]::GetFullPath($Path)
}

function Get-DestinationLabel {
    param([Parameter(Mandatory = $true)][string]$Path)

    $normalized = (Get-FullPath $Path).ToLowerInvariant().Replace("/", "\")
    if ($normalized.Contains("\.codex\skills\hr-ppt")) { return "codex" }
    if ($normalized.Contains("\.claude\skills\hr-ppt")) { return "claude" }
    return "custom"
}

function Assert-SafeDest {
    param([Parameter(Mandatory = $true)][string]$Path)

    $full = Get-FullPath $Path
    $leaf = Split-Path -Leaf $full
    if ($leaf -ne "hr-ppt") {
        throw "Refusing to mirror into a destination not named hr-ppt: $full"
    }

    $normalized = $full.ToLowerInvariant().Replace("/", "\")
    $allowed = (
        $normalized.Contains("\.codex\skills\hr-ppt") -or
        $normalized.Contains("\.claude\skills\hr-ppt")
    )
    if (-not $allowed) {
        throw "Refusing to mirror outside the Codex/Claude hr-ppt skill paths: $full"
    }

    return $full
}

function Invoke-RobocopyChecked {
    param(
        [Parameter(Mandatory = $true)][string]$Source,
        [Parameter(Mandatory = $true)][string]$Destination,
        [string[]]$ExtraArgs = @()
    )

    $args = @($Source, $Destination, "/MIR", "/NFL", "/NDL", "/NJH", "/NJS", "/NP") + $ExtraArgs
    & robocopy @args | Out-Null
    $code = $LASTEXITCODE
    if ($code -gt 7) {
        throw "robocopy failed with exit code $code"
    }
    $global:LASTEXITCODE = 0
}

function Test-ValidGitCheckout {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (-not (Test-Path -LiteralPath (Join-Path $Path ".git") -PathType Container)) {
        return $false
    }

    $oldPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = "Continue"
        & git -C $Path rev-parse --is-inside-work-tree 1>$null 2>$null
        return ($LASTEXITCODE -eq 0)
    }
    finally {
        $ErrorActionPreference = $oldPreference
    }
}

function New-WorkDirectory {
    param([string]$Requested)

    if (-not [string]::IsNullOrWhiteSpace($Requested)) {
        return (New-Item -ItemType Directory -Force -Path $Requested).FullName
    }

    $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $path = Join-Path ([System.IO.Path]::GetTempPath()) "hr-ppt-github-sync-$stamp"
    return (New-Item -ItemType Directory -Force -Path $path).FullName
}

function Ensure-GitHubClone {
    if (-not $script:ClonePath) {
        $script:WorkPath = New-WorkDirectory $WorkDir
        $script:ClonePath = Join-Path $script:WorkPath "hr-ppt"
        & git clone --branch $Ref --depth 1 $RepoUrl $script:ClonePath
        if ($LASTEXITCODE -ne 0) { throw "git clone failed" }
    }
    return $script:ClonePath
}

function Sync-OneDestination {
    param([Parameter(Mandatory = $true)][string]$Destination)

    $destFull = Assert-SafeDest $Destination
    $label = Get-DestinationLabel $destFull

    if ((Test-ValidGitCheckout $destFull) -and -not $Force) {
        $dirty = & git -C $destFull status --porcelain
        if ($dirty) {
            throw "$label hr-ppt has local changes. Commit/push them or rerun with -Force after backing them up."
        }

        & git -C $destFull fetch origin $Ref
        if ($LASTEXITCODE -ne 0) { throw "$label git fetch failed" }

        & git -C $destFull pull --ff-only origin $Ref
        if ($LASTEXITCODE -ne 0) { throw "$label git pull --ff-only failed" }

        $head = & git -C $destFull rev-parse --short HEAD
        Write-Host "$label hr-ppt updated to $head at $destFull"
        return
    }

    $clone = Ensure-GitHubClone
    $backupRoot = Join-Path $script:WorkPath (Join-Path "backup" $label)
    $backup = Join-Path $backupRoot "hr-ppt"

    if (Test-Path -LiteralPath $destFull) {
        New-Item -ItemType Directory -Force -Path $backupRoot | Out-Null
        Invoke-RobocopyChecked -Source $destFull -Destination $backup -ExtraArgs @("/XD", "_sync", "__pycache__")
        Write-Host "$label existing copy backed up to $backup"
    }
    else {
        New-Item -ItemType Directory -Force -Path $destFull | Out-Null
    }

    Invoke-RobocopyChecked -Source $clone -Destination $destFull

    if (-not (Test-Path -LiteralPath (Join-Path $destFull "SKILL.md") -PathType Leaf)) {
        throw "$label mirrored folder is missing SKILL.md"
    }

    $head = & git -C $destFull rev-parse --short HEAD
    Write-Host "$label hr-ppt mirrored from GitHub at $head at $destFull"
}

$script:WorkPath = $null
$script:ClonePath = $null

if (-not [string]::IsNullOrWhiteSpace($Dest)) {
    $destinations = @($Dest)
}
elseif ($Target -eq "codex") {
    $destinations = @($CodexDest)
}
elseif ($Target -eq "claude") {
    $destinations = @($ClaudeDest)
}
else {
    $destinations = @($CodexDest, $ClaudeDest)
}

foreach ($destination in $destinations) {
    Sync-OneDestination -Destination $destination
}

if ($script:WorkPath) {
    Write-Host "Backup/work directory: $script:WorkPath"
}
