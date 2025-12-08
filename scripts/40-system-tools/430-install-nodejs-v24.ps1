param(
  [int]$DesiredMajor = 24
)

# Importar funciones de logging estandarizado
. "$PSScriptRoot\..\lib\logging.ps1"

$scriptTimer = Start-ScriptTimer
Write-ScriptLog -Type 'Start'
$ErrorActionPreference = 'Stop'
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) { throw 'Chocolatey no está instalado. Ejecute 400-install-chocolatey.ps1 primero.' }

function Get-NodeMajor {
  if (-not (Get-Command node -ErrorAction SilentlyContinue)) { return $null }
  $ver = (& node -v 2>$null)
  if (-not $ver) { return $null }
  if ($ver -match 'v(\d+)\.') { return [int]$Matches[1] } else { return $null }
}

$major = Get-NodeMajor
if (-not $major) {
  choco install nodejs -y --no-progress | Out-Null
  # Refrescar variables de entorno para que node esté disponible
  try {
    Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1" -ErrorAction Stop
    refreshenv
  } catch {
    # Si refreshenv no está disponible, actualizar PATH manualmente
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")
  }
  $major = Get-NodeMajor
}
if ($major -ne $DesiredMajor) {
  # Intentar actualizar a la última disponible; Chocolatey no garantiza mayor específico sin versión exacta
  choco upgrade nodejs -y --no-progress | Out-Null
  $major = Get-NodeMajor
}
if ($major -ne $DesiredMajor) {
  Write-Warning ("Node.js instalado con major {0}, pero se solicitó {1}." -f $major, $DesiredMajor)
}


Write-ScriptLog -Type 'End' -StartTime $scriptTimer





