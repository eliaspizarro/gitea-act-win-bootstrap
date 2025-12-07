# Importar funciones de logging estandarizado
. "D:\Develop\personal\gitea-act-win-bootstrap\scripts\00-bootstrap\..\00-bootstrap\logging.ps1"

$scriptTimer = Start-ScriptTimer
Write-ScriptLog -Type 'Start'

param(
  [int]$DesiredMajor = 24
)
$ErrorActionPreference = 'Stop'
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) { throw 'Chocolatey no estÃ¡ instalado. Ejecute 400-install-chocolatey.ps1 primero.' }

function Get-NodeMajor {
  $ver = (& node -v 2>$null)
  if (-not $ver) { return $null }
  if ($ver -match 'v(\d+)\.') { return [int]$Matches[1] } else { return $null }
}

$major = Get-NodeMajor
if (-not $major) {
  choco install nodejs -y --no-progress | Out-Null
  $major = Get-NodeMajor
}
if ($major -ne $DesiredMajor) {
  # Intentar actualizar a la Ãºltima disponible; Chocolatey no garantiza mayor especÃ­fico sin versiÃ³n exacta
  choco upgrade nodejs -y --no-progress | Out-Null
  $major = Get-NodeMajor
}
if ($major -ne $DesiredMajor) {
  Write-Warning ("Node.js instalado con major {0}, pero se solicitÃ³ {1}." -f $major, $DesiredMajor)
}


Write-ScriptLog -Type 'End' -StartTime $scriptTimer

