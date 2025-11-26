# Chromium Windows Build Automation
This repository automates fetching and compiling Chromium milestone 144.0.7548.0 on Windows and provides a GitHub Actions workflow that packages the resulting build output as an artifact archive.
## Repository Layout
- `scripts/` PowerShell utilities for fetching source and prepping the build environment.
- `config/` GN argument presets consumed by GN generation and CI.
- `.github/workflows/` GitHub Actions definitions for automated builds.
## Prerequisites
- Windows 10 or newer with PowerShell 5.1 or PowerShell 7.
- Git, Python 3.11, and Visual Studio 2022 with Desktop development with C++ workload.
- At least 200 GB free disk space and reliable network connectivity for Chromium sync.
- `depot_tools` accessible via `PATH`. The workflow fetches it automatically; locally run `scripts/fetch_chromium.ps1` which ensures the tools are available.
## Local Build Quick Start
1. Clone this repository and ope Run `scripts/fetch_chromium.ps1` to download depot_tools, configure `gclient`, and sync Chromium 144.0.7548.0 into `src`.n an elevated PowerShell prompt.
2.
3. From the `src` directory execute `gn gen out/Release --args=\"$(Get-Content ..\\config\\gn_args.win | Out-String)\"`.
4. Build Chromium with `autoninja -C out/Release chrome`.
5. The resulting binaries and support files live under `src\\out\\Release`.
## Verification
- Run `scripts/test_gn_args.ps1` to ensure the GN args template is syntactically valid before invoking `gn gen`.
- After a successful build, execute `out\\Release\\chrome.exe --version` to confirm the expected milestone is produced.
## Continuous Integration
GitHub Actions workflow `build.yml` performs the same steps on the `windows-2022` runner and publishes the `out/Release` directory as an artifact named `chromium-win-release`.
## Troubleshooting
- If depot_tools is blocked by Windows SmartScreen, unblock via file properties before running the script.
- Re-run `gclient sync` with `--nohooks` and `--with_branch_heads` if the initial sync fails, then invoke `gclient runhooks`.
- Ensure PowerShell execution policy permits running local scripts (`Set-ExecutionPolicy -Scope Process Bypass`).
