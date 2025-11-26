$ErrorActionPreference = "Stop"
$repoRoot = (Resolve-Path "$PSScriptRoot\..").Path
$gnArgsPath = Join-Path $repoRoot "config\gn_args.win"
if (-not (Test-Path $gnArgsPath)) { throw "GN args file not found at $gnArgsPath" }
$pattern = '^[A-Za-z0-9_\.]+\s*='
foreach ($rawLine in Get-Content $gnArgsPath) {
    $line = $rawLine.Trim()
    if ($line.Length -eq 0) { continue }
    if ($line.StartsWith("#")) { continue }
    if ($line -notmatch $pattern) { throw "Invalid GN assignment: $rawLine" }
}
Write-Host "GN args syntax validation passed for $gnArgsPath"

