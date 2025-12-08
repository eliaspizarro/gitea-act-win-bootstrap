# Importar funciones de logging estandarizado
. "$PSScriptRoot\..\lib\logging.ps1"

$scriptTimer = Start-ScriptTimer
Write-ScriptLog -Type 'Start'

$ErrorActionPreference = 'Stop'

# Priorizar variables de entorno para ejecución desatendida
$tempDir = if ($env:GITEA_BOOTSTRAP_TEMP_DIR -and $env:GITEA_BOOTSTRAP_TEMP_DIR -ne '') { $env:GITEA_BOOTSTRAP_TEMP_DIR } else { 'C:\Temp' }
$tmpDir = if ($env:GITEA_BOOTSTRAP_TMP_DIR -and $env:GITEA_BOOTSTRAP_TMP_DIR -ne '') { $env:GITEA_BOOTSTRAP_TMP_DIR } else { $tempDir }

if (-not (Test-Path -LiteralPath $tempDir)) { New-Item -ItemType Directory -Path $tempDir -Force | Out-Null }
if ($tempDir -ne $tmpDir -and -not (Test-Path -LiteralPath $tmpDir)) { 
  New-Item -ItemType Directory -Path $tmpDir -Force | Out-Null 
}

[Environment]::SetEnvironmentVariable('TEMP', $tempDir, 'Machine')
[Environment]::SetEnvironmentVariable('TMP', $tmpDir, 'Machine')
try {
  [Environment]::SetEnvironmentVariable('TEMP', $tempDir, 'User')
  [Environment]::SetEnvironmentVariable('TMP', $tmpDir, 'User')
} catch {}

Write-ScriptLog -Type 'End' -StartTime $scriptTimer
