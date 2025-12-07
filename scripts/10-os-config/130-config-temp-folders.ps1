# Importar funciones de logging estandarizado
. "D:\Develop\personal\gitea-act-win-bootstrap\scripts\00-bootstrap\..\00-bootstrap\logging.ps1"

$scriptTimer = Start-ScriptTimer
Write-ScriptLog -Type 'Start'

$ErrorActionPreference = 'Stop'

# Priorizar variables de entorno para ejecuciÃ³n desatendida
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
  Write-ScriptLog -Type 'End' -StartTime $scriptTimer
} catch {}


