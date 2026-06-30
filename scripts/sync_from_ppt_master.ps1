# Safe upstream intake helper for hr-ppt.
# By default this script only stages a manifest under _sync/. With -Apply it
# copies changed files classified as "auto"; "review" and "protected" files are
# never applied automatically.

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$UpstreamPath,

    [string]$SkillPath = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")).Path,

    [string]$OutDir,

    [switch]$Apply
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Resolve-ExistingDirectory {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Name
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        throw "$Name does not exist or is not a directory: $Path"
    }

    return (Resolve-Path -LiteralPath $Path).Path
}

function Get-RelativePath {
    param(
        [Parameter(Mandatory = $true)][string]$BasePath,
        [Parameter(Mandatory = $true)][string]$FullPath
    )

    $baseFull = [System.IO.Path]::GetFullPath($BasePath)
    if (-not $baseFull.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
        $baseFull += [System.IO.Path]::DirectorySeparatorChar
    }

    $pathFull = [System.IO.Path]::GetFullPath($FullPath)
    $baseUri = New-Object System.Uri($baseFull)
    $pathUri = New-Object System.Uri($pathFull)
    $relativeUri = $baseUri.MakeRelativeUri($pathUri)
    return [System.Uri]::UnescapeDataString($relativeUri.ToString()).Replace("\", "/")
}

function Convert-ToNativePath {
    param([Parameter(Mandatory = $true)][string]$RelativePath)
    return $RelativePath.Replace("/", [System.IO.Path]::DirectorySeparatorChar)
}

function Test-PrefixMatch {
    param(
        [Parameter(Mandatory = $true)][string]$RelativePath,
        [Parameter(Mandatory = $true)][string[]]$Prefixes
    )

    $lower = $RelativePath.ToLowerInvariant()
    foreach ($prefix in $Prefixes) {
        if ($lower.StartsWith($prefix.ToLowerInvariant())) {
            return $true
        }
    }
    return $false
}

function Test-ExactMatch {
    param(
        [Parameter(Mandatory = $true)][string]$RelativePath,
        [Parameter(Mandatory = $true)][string[]]$Paths
    )

    $lower = $RelativePath.ToLowerInvariant()
    foreach ($path in $Paths) {
        if ($lower -eq $path.ToLowerInvariant()) {
            return $true
        }
    }
    return $false
}

function Get-Sha256OrEmpty {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return ""
    }

    return (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash.ToLowerInvariant()
}

function Test-SkippedFile {
    param([Parameter(Mandatory = $true)][string]$RelativePath)

    $lower = $RelativePath.ToLowerInvariant()
    if ($lower -match "(^|/)__pycache__(/|$)") { return $true }
    if ($lower -match "\.pyc$") { return $true }
    if ($lower -match "\.pyo$") { return $true }
    if ($lower -match "(^|/)\.git(/|$)") { return $true }
    if ($lower -match "(^|/)\.venv(/|$)") { return $true }
    if ($lower -match "(^|/)venv(/|$)") { return $true }
    if ($lower -match "^_sync/") { return $true }
    return $false
}

function Get-Category {
    param([Parameter(Mandatory = $true)][string]$RelativePath)

    if ((Test-ExactMatch $RelativePath $script:ProtectedExact) -or
        (Test-PrefixMatch $RelativePath $script:ProtectedPrefixes)) {
        return "protected"
    }

    if ((Test-ExactMatch $RelativePath $script:ManualExact) -or
        (Test-PrefixMatch $RelativePath $script:ManualPrefixes)) {
        return "review"
    }

    return "auto"
}

function Copy-FileCreatingParents {
    param(
        [Parameter(Mandatory = $true)][string]$Source,
        [Parameter(Mandatory = $true)][string]$Destination
    )

    $parent = Split-Path -Parent $Destination
    if (-not (Test-Path -LiteralPath $parent -PathType Container)) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }
    Copy-Item -LiteralPath $Source -Destination $Destination -Force
}

$upstream = Resolve-ExistingDirectory $UpstreamPath "UpstreamPath"
$skill = Resolve-ExistingDirectory $SkillPath "SkillPath"

if (-not (Test-Path -LiteralPath (Join-Path $skill "SKILL.md") -PathType Leaf)) {
    throw "SkillPath does not look like an hr-ppt skill root: $skill"
}

$upstreamHasCoreShape = @("scripts", "references", "templates", "workflows") |
    ForEach-Object { Test-Path -LiteralPath (Join-Path $upstream $_) -PathType Container } |
    Where-Object { $_ } |
    Measure-Object |
    Select-Object -ExpandProperty Count

if ($upstreamHasCoreShape -eq 0) {
    throw "UpstreamPath does not look like a ppt-master checkout: $upstream"
}

if ([string]::IsNullOrWhiteSpace($OutDir)) {
    $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $OutDir = Join-Path $skill (Join-Path "_sync" "ppt-master-$stamp")
}
elseif (-not [System.IO.Path]::IsPathRooted($OutDir)) {
    $OutDir = Join-Path $skill $OutDir
}

$out = New-Item -ItemType Directory -Force -Path $OutDir
$candidateRootNames = @("scripts", "references", "templates", "workflows")
$candidateFileNames = @("SKILL.md", "README.md", "requirements.txt", ".env.example", ".gitignore")

$script:ProtectedExact = @(
    "SKILL.md",
    "README.md",
    "LOCAL_PATCHES.md",
    "UPSTREAM_PPT_MASTER.md",
    "workflows/sync-ppt-master.md",
    "scripts/sync_from_ppt_master.ps1"
)

$script:ProtectedPrefixes = @(
    "templates/decks/hengrui_standard/"
)

$script:ManualExact = @(
    ".env.example",
    ".gitignore",
    "requirements.txt",
    "references/ppt-master-core.md",
    "references/strategist.md",
    "workflows/live-preview.md",
    "scripts/config.py",
    "scripts/server_common.py"
)

$script:ManualPrefixes = @(
    "scripts/confirm_ui/",
    "templates/decks/",
    "templates/layouts/medical_university/"
)

$files = New-Object System.Collections.Generic.List[System.IO.FileInfo]

foreach ($rootName in $candidateRootNames) {
    $rootPath = Join-Path $upstream $rootName
    if (Test-Path -LiteralPath $rootPath -PathType Container) {
        Get-ChildItem -LiteralPath $rootPath -File -Recurse | ForEach-Object {
            $files.Add($_)
        }
    }
}

foreach ($fileName in $candidateFileNames) {
    $filePath = Join-Path $upstream $fileName
    if (Test-Path -LiteralPath $filePath -PathType Leaf) {
        $files.Add((Get-Item -LiteralPath $filePath))
    }
}

$rows = New-Object System.Collections.Generic.List[object]
$applied = 0

foreach ($file in $files) {
    $rel = Get-RelativePath $upstream $file.FullName
    if (Test-SkippedFile $rel) {
        continue
    }

    $nativeRel = Convert-ToNativePath $rel
    $dest = Join-Path $skill $nativeRel
    $srcHash = Get-Sha256OrEmpty $file.FullName
    $destHash = Get-Sha256OrEmpty $dest
    $status = "changed"
    if ($destHash -eq "") {
        $status = "new"
    }
    elseif ($srcHash -eq $destHash) {
        $status = "same"
    }

    $category = Get-Category $rel
    $stagePath = ""

    if ($status -ne "same") {
        $stagePath = Join-Path $out.FullName (Join-Path (Join-Path "candidates" $category) $nativeRel)
        Copy-FileCreatingParents $file.FullName $stagePath

        if ($Apply -and $category -eq "auto") {
            Copy-FileCreatingParents $file.FullName $dest
            $applied += 1
        }
    }

    $rows.Add([pscustomobject]@{
        category = $category
        status = $status
        relative_path = $rel
        source_sha256 = $srcHash
        current_sha256 = $destHash
        staged_path = $stagePath
        applied = ($Apply -and $category -eq "auto" -and $status -ne "same")
    })
}

$manifestPath = Join-Path $out.FullName "sync_manifest.csv"
$rows |
    Sort-Object category, status, relative_path |
    Export-Csv -NoTypeInformation -Encoding UTF8 -Path $manifestPath

$report = New-Object System.Collections.Generic.List[string]
$report.Add("# ppt-master Sync Report")
$report.Add("")
$report.Add("- Upstream: $upstream")
$report.Add("- HR-PPT skill: $skill")
$report.Add("- Staging directory: $($out.FullName)")
$report.Add("- Apply auto candidates: $($Apply.IsPresent)")
$report.Add("- Auto files applied: $applied")
$report.Add("")

foreach ($category in @("auto", "review", "protected")) {
    $categoryRows = @($rows | Where-Object { $_.category -eq $category })
    $changedRows = @($categoryRows | Where-Object { $_.status -ne "same" })
    $report.Add("## $category")
    $report.Add("")
    $report.Add("- Total scanned: $($categoryRows.Count)")
    $report.Add("- New or changed: $($changedRows.Count)")
    $report.Add("")

    if ($changedRows.Count -eq 0) {
        $report.Add("No new or changed files.")
        $report.Add("")
        continue
    }

    foreach ($row in ($changedRows | Sort-Object relative_path)) {
        $report.Add("- [$($row.status)] $($row.relative_path)")
    }
    $report.Add("")
}

$report.Add("## Next Steps")
$report.Add("")
$report.Add("1. Read this report and sync_manifest.csv.")
$report.Add("2. Keep protected files as local overlay.")
$report.Add("3. Manually merge review files.")
$report.Add("4. Run the regression checklist in LOCAL_PATCHES.md.")
$report.Add("5. Record the upstream commit and decisions in UPSTREAM_PPT_MASTER.md.")

$reportPath = Join-Path $out.FullName "sync_report.md"
$report | Set-Content -Encoding UTF8 -Path $reportPath

if ($Apply -and -not (Test-Path -LiteralPath (Join-Path $skill ".git") -PathType Container)) {
    Write-Warning "Applied auto candidates in a non-Git installed copy. Mirror accepted changes back to the source repository when available."
}

Write-Host "Sync report: $reportPath"
Write-Host "Manifest: $manifestPath"
if ($Apply) {
    Write-Host "Applied auto candidates: $applied"
}
