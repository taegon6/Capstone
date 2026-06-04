$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$pythonDir = Join-Path $root "python"

Set-Location $pythonDir

if (-not $env:API_HOST) {
    $env:API_HOST = "0.0.0.0"
}

if (-not $env:API_PORT) {
    $env:API_PORT = "8000"
}

if (-not $env:API_CORS_ORIGINS) {
    $env:API_CORS_ORIGINS = "*"
}

Write-Host "Starting CSI Pose API for Android access..."
Write-Host "Host: $env:API_HOST"
Write-Host "Port: $env:API_PORT"
Write-Host "From Android, use http://<this-PC-LAN-IP>:$env:API_PORT"

python api_server.py
