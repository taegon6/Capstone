param(
    [string]$Port = "COM11",
    [int]$Seconds = 30
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $Root

$labels = @("empty", "static_person", "moving_person")

foreach ($label in $labels) {
    Write-Host ""
    Write-Host "Prepare scene: $label"
    Write-Host "Press Enter to start $Seconds seconds capture..."
    Read-Host | Out-Null
    python scripts/capture_csi_serial.py --port $Port --seconds $Seconds --label $label --echo
}

Write-Host ""
Write-Host "Dataset capture finished. Logs are in data/csi_logs"

