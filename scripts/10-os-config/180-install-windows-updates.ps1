# Importar funciones de logging estandarizado
. "$PSScriptRoot\..\lib\logging.ps1"

$scriptTimer = Start-ScriptTimer
Write-ScriptLog -Type 'Start'

$ErrorActionPreference = 'Stop'

try {
  Write-Host "Buscando actualizaciones de Windows..." -ForegroundColor White
  
  # Usar cliente nativo de Windows Update
  Start-Process -FilePath "UsoClient.exe" -ArgumentList "StartScan" -Wait
  
  Write-Host "Instalando actualizaciones encontradas..." -ForegroundColor White
  
  Start-Process -FilePath "UsoClient.exe" -ArgumentList "StartInstall" -Wait
  
  Write-Host "Proceso de actualizacion completado" -ForegroundColor Green
  
} catch {
  Write-Host "Error durante la instalacion de actualizaciones: $($_.Exception.Message)" -ForegroundColor Red
  throw
}

Write-ScriptLog -Type 'End' -StartTime $scriptTimer
