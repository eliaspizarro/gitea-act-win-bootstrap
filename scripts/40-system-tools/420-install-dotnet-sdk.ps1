# Importar funciones de logging estandarizado
. "D:\Develop\personal\gitea-act-win-bootstrap\scripts\00-bootstrap\..\00-bootstrap\logging.ps1"

$scriptTimer = Start-ScriptTimer
Write-ScriptLog -Type 'Start'

param(
  [string]$Channel = '8.0'  # Canal LTS por defecto
)
$ErrorActionPreference = 'Stop'

# Priorizar variables de entorno para ejecuciÃ³n desatendida
$Channel = if ($env:GITEA_BOOTSTRAP_DOTNET_CHANNEL -and $env:GITEA_BOOTSTRAP_DOTNET_CHANNEL -ne '') { $env:GITEA_BOOTSTRAP_DOTNET_CHANNEL } else { $Channel }
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) { throw 'Chocolatey no estÃ¡ instalado. Ejecute 400-install-chocolatey.ps1 primero.' }
$pkg = "dotnet-$Channel-sdk"
$dotnet = Get-Command dotnet -ErrorAction SilentlyContinue
if ($dotnet) {
  $has = (& dotnet --list-sdks) -match "^$Channel" | Select-Object -First 1
  if ($has) { return }
}
choco install $pkg -y --no-progress | Out-Null


Write-ScriptLog -Type 'End' -StartTime $scriptTimer

