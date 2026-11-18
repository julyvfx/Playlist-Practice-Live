# ============================================================
#  INICIAR_EMISORA.PS1 - ROCKANROLLA v2.0
#  Arranca ZaraRadio y el servidor web de la pantalla (puerto 8080)
#
#  Uso: clic derecho -> Ejecutar con PowerShell
#       (o: powershell -ExecutionPolicy Bypass -File iniciar_emisora.ps1)
# ============================================================

$ErrorActionPreference = "SilentlyContinue"

$raiz = Split-Path -Parent $MyInvocation.MyCommand.Path
$zara = "C:\Program Files (x86)\ZaraSoft\ZaraRadio\ZaraRadio.exe"

# Busca Python en las ubicaciones comunes
$python = @(
    "$env:LOCALAPPDATA\Python\pythoncore-3.14-64\python.exe",
    "$env:LOCALAPPDATA\Programs\Python\Python314\python.exe",
    "$env:LOCALAPPDATA\Programs\Python\Python313\python.exe",
    "$env:LOCALAPPDATA\Programs\Python\Python312\python.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $python) { $python = (Get-Command python.exe).Source }

# 1) ZaraRadio (abre la ultima playlist usada; ver ZARA\config_rockanrolla_v2.reg)
if (-not (Get-Process -Name ZaraRadio)) {
    Start-Process -FilePath $zara -WorkingDirectory (Split-Path -Parent $zara)
    Start-Sleep -Seconds 3
}

# 2) Servidor web para la pantalla OBS (sirve este paquete en el puerto 8080)
if (-not (Get-NetTCPConnection -LocalPort 8080 -State Listen)) {
    Start-Process -FilePath $python `
        -ArgumentList "-m", "http.server", "8080", "--bind", "0.0.0.0", "--directory", "`"$raiz`"" `
        -WindowStyle Hidden
}

Write-Host ""
Write-Host " ROCKANROLLA v2.0 en marcha" -ForegroundColor Red
Write-Host "  - ZaraRadio: reproduciendo (playlist 80s por defecto)" -ForegroundColor Gray
Write-Host "  - Pantalla OBS: http://localhost:8080/web/index.html" -ForegroundColor Yellow
Write-Host "  - Pantalla simple: http://localhost:8080/web/pantalla_pro.html.html" -ForegroundColor Gray
