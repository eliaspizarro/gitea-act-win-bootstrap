# Importar funciones de logging estandarizado
. "$PSScriptRoot\..\lib\logging.ps1"

$scriptTimer = Start-ScriptTimer
Write-ScriptLog -Type 'Start'

$ErrorActionPreference = 'Stop'

# Priorizar variables de entorno para ejecución desatendida
$tempDir = if ($env:GITEA_BOOTSTRAP_TEMP_DIR -and $env:GITEA_BOOTSTRAP_TEMP_DIR -ne '') { $env:GITEA_BOOTSTRAP_TEMP_DIR } else { 'C:\Temp' }

if (-not (Test-Path -LiteralPath $tempDir)) { New-Item -ItemType Directory -Path $tempDir -Force | Out-Null }

[Environment]::SetEnvironmentVariable('TEMP', $tempDir, 'Machine')
[Environment]::SetEnvironmentVariable('TMP', $tempDir, 'Machine')
try {
  [Environment]::SetEnvironmentVariable('TEMP', $tempDir, 'User')
  [Environment]::SetEnvironmentVariable('TMP', $tempDir, 'User')
} catch {}

Write-ScriptLog -Type 'End' -StartTime $scriptTimer
