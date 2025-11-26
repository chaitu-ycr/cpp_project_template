<#
windows_build.ps1

Performs a clean configure + build on Windows using CMake.

Usage:
  From a Developer PowerShell for Visual Studio (recommended):
    .\scripts\windows_build.ps1

  Options:
    -Generator <string>    CMake generator (default: "NMake Makefiles")
    -BuildType <string>    Build type/config (default: "Release")
    -RunTests              Run `ctest` after a successful build

Examples:
  .\scripts\windows_build.ps1 -Generator "Visual Studio 17 2022" -BuildType Debug
  .\scripts\windows_build.ps1 -Generator "Ninja" -RunTests
#>

param(
    [string]$Generator = "NMake Makefiles",
    [string]$BuildType = "Release",
    [switch]$RunTests
)

Set-StrictMode -Version Latest

Write-Host "Generator: $Generator" -ForegroundColor Cyan
Write-Host "BuildType: $BuildType" -ForegroundColor Cyan

# Ensure script is run from repository root where CMakeLists.txt is located
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
Push-Location $scriptDir\.. | Out-Null

try {
    $buildDir = Join-Path -Path (Get-Location) -ChildPath 'build_win'

    if (Test-Path $buildDir) {
        Write-Host "Removing existing build directory: $buildDir" -ForegroundColor Yellow
        Remove-Item -Recurse -Force $buildDir -ErrorAction Stop
    }

    Write-Host "Configuring (cmake) ..." -ForegroundColor Green

    $cmakeArgs = @('-S', '.', '-B', 'build_win', '-G', $Generator)

    # Add architecture flag for Visual Studio generators if not present
    if ($Generator -match 'Visual Studio' -and -not ($cmakeArgs -contains '-A')) {
        $cmakeArgs += ('-A', 'x64')
    }

    # For single-config generators, set CMAKE_BUILD_TYPE
    if ($Generator -notmatch 'Visual Studio') {
        $cmakeArgs += ('-DCMAKE_BUILD_TYPE=' + $BuildType)
    }

    & cmake @cmakeArgs
    if ($LASTEXITCODE -ne 0) { throw "cmake configure failed (exit $LASTEXITCODE)" }

    Write-Host "Building (cmake --build) ..." -ForegroundColor Green
    # Use CMake's --parallel option which works across generators (MSBuild, Ninja, NMake)
    & cmake --build build_win --config $BuildType --parallel
    if ($LASTEXITCODE -ne 0) { throw "cmake build failed (exit $LASTEXITCODE)" }

    if ($RunTests) {
        Write-Host "Running tests (ctest) ..." -ForegroundColor Green
        Push-Location build_win
        & ctest -C $BuildType --output-on-failure
        $ctestCode = $LASTEXITCODE
        Pop-Location
        if ($ctestCode -ne 0) { throw "ctest failed (exit $ctestCode)" }
    }

    Write-Host "SUCCESS: Build completed." -ForegroundColor Green
}
catch {
    Write-Host "ERROR: $_" -ForegroundColor Red
    exit 1
}
finally {
    Pop-Location | Out-Null
}
