# One-command hr-ppt synchronization across GitHub, Codex, and Claude.
# GitHub is the durable ledger. This script promotes one dirty local copy to
# GitHub, then fast-forwards every installed copy from GitHub.

[CmdletBinding()]
param(
    [string]$RepoUrl = "https://github.com/Linglong-AI/hr-ppt.git",
    [string]$Ref = "main",
    [string]$CodexDest = (Join-Path $HOME ".codex\skills\hr-ppt"),
    [string]$ClaudeDest = (Join-Path $HOME ".claude\skills\hr-ppt"),
    [string]$CommitMessage,
    [switch]$ForceRepair
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-FullPath {
    param([Parameter(Mandatory = $true)][string]$Path)
    return [System.IO.Path]::GetFullPath($Path)
}

function Assert-SafeSkillPath {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Label
    )

    $full = Get-FullPath $Path
    if ((Split-Path -Leaf $full) -ne "hr-ppt") {
        throw "$Label path must end in hr-ppt: $full"
    }

    $normalized = $full.ToLowerInvariant().Replace("/", "\")
    if ($Label -eq "codex" -and -not $normalized.Contains("\.codex\skills\hr-ppt")) {
        throw "Refusing unsafe Codex path: $full"
    }
    if ($Label -eq "claude" -and -not $normalized.Contains("\.claude\skills\hr-ppt")) {
        throw "Refusing unsafe Claude path: $full"
    }
    return $full
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

function Get-GitStatus {
    param([Parameter(Mandatory = $true)][string]$Path)
    return @(& git -C $Path status --porcelain)
}

function Ensure-GitIdentity {
    param([Parameter(Mandatory = $true)][string]$Path)

    $name = & git -C $Path config user.name
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($name)) {
        & git -C $Path config user.name Codex
        if ($LASTEXITCODE -ne 0) { throw "failed to set local git user.name" }
    }

    $email = & git -C $Path config user.email
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($email)) {
        & git -C $Path config user.email codex@local
        if ($LASTEXITCODE -ne 0) { throw "failed to set local git user.email" }
    }
}

function Get-ShortHead {
    param([Parameter(Mandatory = $true)][string]$Path)
    return (& git -C $Path rev-parse --short HEAD).Trim()
}

function Repair-FromGitHub {
    param(
        [Parameter(Mandatory = $true)][string]$Label,
        [Parameter(Mandatory = $true)][string]$Path
    )

    $scriptPath = Join-Path $CodexDest "scripts\sync_local_from_github.ps1"
    if (-not (Test-Path -LiteralPath $scriptPath -PathType Leaf)) {
        throw "Cannot repair $Label because sync_local_from_github.ps1 is missing at $scriptPath"
    }

    $targetArg = if ($Label -eq "codex") { "codex" } else { "claude" }
    & powershell -ExecutionPolicy Bypass -File $scriptPath -Target $targetArg -RepoUrl $RepoUrl -Ref $Ref -Force:$ForceRepair
    if ($LASTEXITCODE -ne 0) { throw "$Label repair from GitHub failed" }
}

function Promote-LocalChanges {
    param(
        [Parameter(Mandatory = $true)][string]$Label,
        [Parameter(Mandatory = $true)][string]$Path
    )

    Ensure-GitIdentity $Path

    if ([string]::IsNullOrWhiteSpace($CommitMessage)) {
        $stamp = Get-Date -Format "yyyy-MM-dd HH:mm"
        $message = "Sync hr-ppt from $Label ($stamp)"
    }
    else {
        $message = $CommitMessage
    }

    & git -C $Path add -A
    if ($LASTEXITCODE -ne 0) { throw "$Label git add failed" }

    $remaining = @(Get-GitStatus $Path)
    if ($remaining.Count -gt 0) {
        & git -C $Path commit -m $message
        if ($LASTEXITCODE -ne 0) { throw "$Label git commit failed" }
        Write-Host "$Label local changes committed: $message"
    }

    & git -C $Path fetch origin $Ref
    if ($LASTEXITCODE -ne 0) { throw "$Label git fetch failed" }

    & git -C $Path pull --rebase origin $Ref
    if ($LASTEXITCODE -ne 0) {
        throw "$Label rebase failed. Resolve the conflict in $Path, then rerun sync_everywhere.ps1."
    }

    & git -C $Path push origin "HEAD:$Ref"
    if ($LASTEXITCODE -ne 0) { throw "$Label git push failed" }

    Write-Host "$Label changes pushed to GitHub at $(Get-ShortHead $Path)"
}

function Pull-CleanCopy {
    param(
        [Parameter(Mandatory = $true)][string]$Label,
        [Parameter(Mandatory = $true)][string]$Path
    )

    & git -C $Path fetch origin $Ref
    if ($LASTEXITCODE -ne 0) { throw "$Label git fetch failed" }

    & git -C $Path pull --ff-only origin $Ref
    if ($LASTEXITCODE -ne 0) { throw "$Label git pull --ff-only failed" }

    Write-Host "$Label synchronized at $(Get-ShortHead $Path)"
}

$codexPath = Assert-SafeSkillPath -Path $CodexDest -Label "codex"
$claudePath = Assert-SafeSkillPath -Path $ClaudeDest -Label "claude"
$copies = @(
    [pscustomobject]@{ Label = "codex"; Path = $codexPath },
    [pscustomobject]@{ Label = "claude"; Path = $claudePath }
)

foreach ($copy in $copies) {
    if (-not (Test-Path -LiteralPath $copy.Path -PathType Container) -or
        -not (Test-ValidGitCheckout $copy.Path)) {
        Repair-FromGitHub -Label $copy.Label -Path $copy.Path
    }
}

$dirtyCopies = @()
foreach ($copy in $copies) {
    $status = @(Get-GitStatus $copy.Path)
    if ($status.Count -gt 0) {
        $dirtyCopies += [pscustomobject]@{
            Label = $copy.Label
            Path = $copy.Path
            Count = $status.Count
        }
    }
}

if ($dirtyCopies.Count -gt 1) {
    $details = ($dirtyCopies | ForEach-Object { "$($_.Label): $($_.Count) changed item(s)" }) -join "; "
    throw "Both local copies have uncommitted changes ($details). Commit or resolve one side first, then rerun."
}

if ($dirtyCopies.Count -eq 1) {
    Promote-LocalChanges -Label $dirtyCopies[0].Label -Path $dirtyCopies[0].Path
}

foreach ($copy in $copies) {
    $status = @(Get-GitStatus $copy.Path)
    if ($status.Count -gt 0) {
        throw "$($copy.Label) still has local changes after promotion. Refusing to pull over them."
    }
    Pull-CleanCopy -Label $copy.Label -Path $copy.Path
}

$codexHead = Get-ShortHead $codexPath
$claudeHead = Get-ShortHead $claudePath
if ($codexHead -ne $claudeHead) {
    throw "Codex and Claude ended on different commits: codex=$codexHead claude=$claudeHead"
}

Write-Host "hr-ppt synchronized everywhere at $codexHead"
