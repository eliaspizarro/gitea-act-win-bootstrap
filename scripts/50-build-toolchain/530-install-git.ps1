# Importar funciones de logging estandarizado
. "$PSScriptRoot\..\lib\logging.ps1"

$scriptTimer = Start-ScriptTimer
Write-ScriptLog -Type 'Start'

$ErrorActionPreference = 'Stop'
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) { throw 'Chocolatey no está instalado. Ejecute 400-install-chocolatey.ps1 primero.' }
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  choco install git -y --no-progress | Out-Null
}
try { & git config --system core.longpaths true 2>$null } catch {}

Write-ScriptLog -Type 'End' -StartTime $scriptTimer




