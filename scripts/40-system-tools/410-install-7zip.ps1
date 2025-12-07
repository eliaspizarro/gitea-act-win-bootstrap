# Importar funciones de logging estandarizado
. "D:\Develop\personal\gitea-act-win-bootstrap\scripts\00-bootstrap\..\00-bootstrap\logging.ps1"

$scriptTimer = Start-ScriptTimer
Write-ScriptLog -Type 'Start'

$ErrorActionPreference = 'Stop'
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) { throw 'Chocolatey no estÃ¡ instalado. Ejecute 400-install-chocolatey.ps1 primero.' }
if (-not (Get-Command 7z -ErrorAction SilentlyContinue)) {
  choco install 7zip.commandline -y --no-progress | Out-Null
}


Write-ScriptLog -Type 'End' -StartTime $scriptTimer

