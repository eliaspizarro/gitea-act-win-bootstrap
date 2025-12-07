# Importar funciones de logging estandarizado
. "$PSScriptRoot\..\00-bootstrap\logging.ps1"

$scriptTimer = Start-ScriptTimer
Write-ScriptLog -Type 'Start'

$ErrorActionPreference = 'Stop'
try { powercfg /SETACTIVE SCHEME_MAX | Out-Null } catch {}

Write-ScriptLog -Type 'End' -StartTime $scriptTimer

