# Importar funciones de logging estandarizado
. "$PSScriptRoot\..\lib\logging.ps1"

$scriptTimer = Start-ScriptTimer
Write-ScriptLog -Type 'Start'

$ErrorActionPreference = 'Stop'

try {
  Write-Host "Instalando modulo PSWindowsUpdate si no esta presente..." -ForegroundColor White
  if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
    Install-Module -Name PSWindowsUpdate -Force -Confirm:$false
    Write-Host "Modulo PSWindowsUpdate instalado correctamente" -ForegroundColor Green
  } else {
    Write-Host "Modulo PSWindowsUpdate ya esta presente" -ForegroundColor Yellow
  }

  Import-Module PSWindowsUpdate
  
  Write-Host "Buscando actualizaciones disponibles..." -ForegroundColor White
  $updates = Get-WUList
  
  if ($updates.Count -eq 0) {
    Write-Host "No hay actualizaciones disponibles" -ForegroundColor Green
  } else {
    Write-Host "Se encontraron $($updates.Count) actualizaciones. Iniciando instalacion..." -ForegroundColor Yellow
    Install-WindowsUpdate -AcceptAll -IgnoreReboot -Verbose
    Write-Host "Actualizaciones instaladas correctamente (sin reinicio automatico)" -ForegroundColor Green
  }
  
} catch {
  Write-Host "Error durante la instalacion de actualizaciones: $($_.Exception.Message)" -ForegroundColor Red
  throw
}

Write-ScriptLog -Type 'End' -StartTime $scriptTimer
