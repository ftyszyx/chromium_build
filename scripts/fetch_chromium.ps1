param(
    [string]$Version = "144.0.7548.0",
    [string]$RepoRoot = (Resolve-Path "$PSScriptRoot\..").Path,
    [string]$DepotToolsDir,
    [string]$ChromiumSrcDir
)
$ErrorActionPreference = "Stop"
if (-not $DepotToolsDir) { $DepotToolsDir = Join-Path $RepoRoot "depot_tools" }
if (-not $ChromiumSrcDir) { $ChromiumSrcDir = Join-Path $RepoRoot "src" }
function Invoke-CommandChecked {
    param([string]$Command,[string[]]$Arguments)
    Write-Host ">> $Command $($Arguments -join ' ')"
    $process = Start-Process -FilePath $Command -ArgumentList $Arguments -NoNewWindow -Wait -PassThru
    if ($process.ExitCode -ne 0) { throw "$Command exited with $($process.ExitCode)" }
}
if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw "git is not available on PATH. Install Git before running this script." }
if (-not (Test-Path $DepotToolsDir)) {
    Write-Host "Cloning depot_tools into $DepotToolsDir"
    Invoke-CommandChecked -Command "git" -Arguments @("clone","https://chromium.googlesource.com/chromium/tools/depot_tools.git",$DepotToolsDir)
} else {
    Write-Host "Updating existing depot_tools checkout at $DepotToolsDir"
    Invoke-CommandChecked -Command "git" -Arguments @("-C",$DepotToolsDir,"pull","--rebase","--autostash")
}
$env:DEPOT_TOOLS_WIN_TOOLCHAIN = "0"
if (-not ($env:PATH.Split(";") -contains $DepotToolsDir)) { $env:PATH = "$DepotToolsDir;$env:PATH" }
Set-Location $RepoRoot
if (-not (Test-Path $ChromiumSrcDir)) {
    Write-Host "Fetching Chromium source into $ChromiumSrcDir"
    Invoke-CommandChecked -Command (Join-Path $DepotToolsDir "fetch.bat") -Arguments @("--nohooks","chromium")
} else {
    Write-Host "Chromium source directory already present at $ChromiumSrcDir"
}
Set-Location $ChromiumSrcDir
Invoke-CommandChecked -Command "git" -Arguments @("fetch","origin","--tags","--force")
Invoke-CommandChecked -Command "git" -Arguments @("checkout","refs/tags/$Version")
Invoke-CommandChecked -Command "gclient" -Arguments @("sync","--with_branch_heads","--with_tags","--nohooks",$("--revision=src@refs/tags/$Version"))
Invoke-CommandChecked -Command "gclient" -Arguments @("runhooks")
Write-Host "Chromium $Version is ready under $ChromiumSrcDir"

