param(
    [switch]$SkipMatlab
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $Root

Write-Host "== Python mock pose demo =="
python python/mock_pose_demo.py

Write-Host ""
Write-Host "== Python tests =="
Push-Location python
python -m pytest tests -p no:cacheprovider
Pop-Location

if (-not $SkipMatlab) {
    Write-Host ""
    Write-Host "== MATLAB tests =="
    matlab -batch "addpath(genpath('matlab')); results=runtests('matlab/tests'); assertSuccess(results);"

    Write-Host ""
    Write-Host "== MATLAB real CSI dataset comparison =="
    matlab -batch "run('matlab/examples/run_real_csi_dataset_comparison.m'); close all;"

    Write-Host ""
    Write-Host "== MATLAB public HomeHAR subset demo =="
    matlab -batch "run('matlab/examples/run_public_homehar_demo.m'); close all;"
}

Write-Host ""
Write-Host "Verification complete."

