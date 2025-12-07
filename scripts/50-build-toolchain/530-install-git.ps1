# Importar funciones de logging estandarizado
. "D:\Develop\personal\gitea-act-win-bootstrap\scripts\00-bootstrap\..\00-bootstrap\logging.ps1"

$scriptTimer = Start-ScriptTimer
Write-ScriptLog -Type 'Start'

$ErrorActionPreference = 'Stop'
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) { throw 'Chocolatey no estÃ¡ instalado. Ejecute 400-install-chocolatey.ps1 primero.' }
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  choco install git -y --no-progress | Out-Null
}
try { & git config --system core.longpaths true 2>$null } catch {}


