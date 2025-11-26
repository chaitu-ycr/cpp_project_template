<#
windows_run.ps1

Finds and runs built Windows executables in the `build` directory.

Usage:
  .\scripts\windows_run.ps1 -All
  .\scripts\windows_run.ps1 -Name calculator_app -Config Release

Options:
  -Name <string>   Name of binary to run (without extension). Example: calculator_app
  -All             Run all known binaries found (calculator_app, hello_world_app, unit_tests)
  -Config <string> Build configuration for multi-config builds (default: Release)
#>

param(
    [string]$Name,
    [switch]$All,
    [string]$Config = 'Release',
    [string[]]$Args = @(),
    [switch]$List,
    [switch]$DryRun
)

Set-StrictMode -Version Latest

# Discover known targets by parsing CMakeLists.txt (add_executable)
$known = @()
Get-ChildItem -Path . -Recurse -Filter CMakeLists.txt -ErrorAction SilentlyContinue | ForEach-Object {
    $content = Get-Content -LiteralPath $_.FullName -ErrorAction SilentlyContinue -Raw
    if ($null -ne $content) {
        $matches = [regex]::Matches($content, 'add_executable\s*\(\s*([A-Za-z0-9_\-]+)', 'IgnoreCase')
        foreach ($m in $matches) { $known += $m.Groups[1].Value }
    }
}

# Add some default known names to cover cases where parsing might miss names
$defaults = @('calculator_app','hello_app','hello_world_app','unit_tests')
foreach ($d in $defaults) { if (-not ($known -contains $d)) { $known += $d } }

# Make unique and keep order
$known = $known | Select-Object -Unique

if ($List) {
    Write-Host "Discovered targets:" -ForegroundColor Cyan
    foreach ($k in $known) { Write-Host " - $k" }
    exit 0
}

if ($DryRun) {
    Write-Host "Dry-run mode: discovered executables:" -ForegroundColor Yellow
}

# Ensure script is executed from repo root
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
Push-Location $scriptDir\.. | Out-Null

try {
    if (-not (Test-Path .\build)) {
        Write-Host "No build directory found at './build'" -ForegroundColor Yellow
        exit 2
    }

    if ($All) {
        $toRun = $known
    }
    elseif ($Name) {
        $toRun = @($Name)
    }
    else {
        Write-Host "Specify -Name <binary> or -All" -ForegroundColor Yellow
        exit 2
    }

    # Find executables for each requested name
    foreach ($n in $toRun) {
        Write-Host "Searching for '$n' in build tree..." -ForegroundColor Cyan

        # Prefer multi-config layout (e.g. build/**/Config/<name>.exe) and config-specific dirs
        $candidates = @()

        # First look for <name>.exe anywhere
        $candidates += Get-ChildItem -Path .\build -Recurse -Filter ($n + '.exe') -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName -ErrorAction SilentlyContinue

        $candidates = $candidates | Select-Object -Unique

        if (@($candidates).Count -eq 0) {
            Write-Host "Could not find executable for '$n'" -ForegroundColor Yellow
            continue
        }

        foreach ($exe in $candidates) {
            if ($DryRun) {
                Write-Host "  $exe" -ForegroundColor Cyan
            }
            else {
                Write-Host "Running: $exe" -ForegroundColor Green
                $exeDir = Split-Path -Parent $exe
                Push-Location $exeDir
                try {
                    if ($Args -and $Args.Count -gt 0) {
                        & "$exe" @Args
                    }
                    else {
                        & "$exe"
                    }
                    $code = $LASTEXITCODE
                    if ($code -ne 0) {
                        Write-Host "Process exited with code $code" -ForegroundColor Yellow
                    }
                }
                catch {
                    Write-Host "Failed to run $exe : $($_.Exception.Message)" -ForegroundColor Red
                }
                finally {
                    Pop-Location
                }
            }
        }
    }
}
finally {
    Pop-Location | Out-Null
}
