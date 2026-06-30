# Sync the installed hr-ppt skill from its GitHub source of truth.
# Normal case: if the installed folder is a valid Git checkout, fast-forward it.
# Repair case: if the installed folder is not a Git checkout, clone GitHub to a
# temporary directory, back up the installed folder, and mirror the clone in.

[CmdletBinding()]
param(
    [string]$RepoUrl = "https://github.com/Linglong-AI/hr-ppt.git",
    [string]$Ref = "main",
    [string]$Dest = (Join-Path $HOME ".codex\skills\hr-ppt"),
    [string]$WorkDir,
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-FullPath {
    param([Parameter(Mandatory = $true)][string]$Path)
    return [System.IO.Path]::GetFullPath($Path)
}

function Assert-SafeDest {
    param([Parameter(Mandatory = $true)][string]$Path)

    $full = Get-FullPath $Path
    $leaf = Split-Path -Leaf $full
    if ($leaf -ne "hr-ppt") {
        throw "Refusing to mirror into a destination not named hr-ppt: $full"
    }

    $normalized = $full.ToLowerInvariant().Replace("/", "\")
    if (-not $normalized.Contains("\.codex\skills\hr-ppt")) {
        throw "Refusing to mirror outside the Codex hr-ppt skill path: $full"
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

$destFull = Assert-SafeDest $Dest

if ((Test-ValidGitCheckout $destFull) -and -not $Force) {
    $dirty = & git -C $destFull status --porcelain
    if ($dirty) {
        throw "Installed hr-ppt has local changes. Commit/push them or rerun with -Force after backing them up."
    }

    & git -C $destFull fetch origin $Ref
    if ($LASTEXITCODE -ne 0) { throw "git fetch failed" }

    & git -C $destFull pull --ff-only origin $Ref
    if ($LASTEXITCODE -ne 0) { throw "git pull --ff-only failed" }

    $head = & git -C $destFull rev-parse --short HEAD
    Write-Host "Installed hr-ppt updated to $head"
    exit 0
}

$work = New-WorkDirectory $WorkDir
$clone = Join-Path $work "hr-ppt"
$backupRoot = Join-Path $work "backup"
$backup = Join-Path $backupRoot "hr-ppt"

& git clone --branch $Ref --depth 1 $RepoUrl $clone
if ($LASTEXITCODE -ne 0) { throw "git clone failed" }

if (Test-Path -LiteralPath $destFull) {
    New-Item -ItemType Directory -Force -Path $backupRoot | Out-Null
    Invoke-RobocopyChecked -Source $destFull -Destination $backup -ExtraArgs @("/XD", "_sync", "__pycache__")
    Write-Host "Existing installed copy backed up to $backup"
}
else {
    New-Item -ItemType Directory -Force -Path $destFull | Out-Null
}

Invoke-RobocopyChecked -Source $clone -Destination $destFull

if (-not (Test-Path -LiteralPath (Join-Path $destFull "SKILL.md") -PathType Leaf)) {
    throw "Mirrored folder is missing SKILL.md"
}

$head = & git -C $destFull rev-parse --short HEAD
Write-Host "Installed hr-ppt mirrored from GitHub at $head"
Write-Host "Backup/work directory: $work"
