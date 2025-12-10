# Importar funciones de logging estandarizado
. "$PSScriptRoot\..\lib\logging.ps1"

$scriptTimer = Start-ScriptTimer
Write-ScriptLog -Type 'Start'

$ErrorActionPreference = 'Stop'

try {
  Write-Log "Instalando módulo PSWindowsUpdate si no está presente..."
  if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
    Install-Module -Name PSWindowsUpdate -Force -Confirm:$false
    Write-Log "Módulo PSWindowsUpdate instalado correctamente"
  } else {
    Write-Log "Módulo PSWindowsUpdate ya está presente"
  }

  Import-Module PSWindowsUpdate
  
  Write-Log "Buscando actualizaciones disponibles..."
  $updates = Get-WUList
  
  if ($updates.Count -eq 0) {
    Write-Log "No hay actualizaciones disponibles"
  } else {
    Write-Log "Se encontraron $($updates.Count) actualizaciones. Iniciando instalación..."
    Install-WindowsUpdate -AcceptAll -IgnoreReboot -Verbose
    Write-Log "Actualizaciones instaladas correctamente (sin reinicio automático)"
  }
  
} catch {
  Write-Log "Error durante la instalación de actualizaciones: $($_.Exception.Message)" -Type 'Error'
  throw
}

Write-ScriptLog -Type 'End' -StartTime $scriptTimer
