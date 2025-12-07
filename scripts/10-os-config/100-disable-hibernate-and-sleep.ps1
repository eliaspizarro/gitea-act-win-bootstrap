# Importar funciones de logging estandarizado
. "$PSScriptRoot\..\00-bootstrap\logging.ps1"

$scriptTimer = Start-ScriptTimer
Write-ScriptLog -Type 'Start'

$ErrorActionPreference = 'Stop'

try {
  powercfg -h off | Out-Null
} catch {}
try { powercfg /x standby-timeout-ac 0 | Out-Null } catch {}
try { powercfg /x standby-timeout-dc 0 | Out-Null } catch {}

Write-ScriptLog -Type 'End' -StartTime $scriptTimer

