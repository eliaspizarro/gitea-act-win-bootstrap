param(
  [string]$User = 'gitea-runner',
  [SecureString]$Password
)

# Importar funciones de logging estandarizado
. "$PSScriptRoot\..\lib\logging.ps1"

$scriptTimer = Start-ScriptTimer
Write-ScriptLog -Type 'Start'

$ErrorActionPreference = 'Stop'

# Priorizar variables de entorno para ejecución desatendida
$User = if ($env:GITEA_BOOTSTRAP_USER) { $env:GITEA_BOOTSTRAP_USER } else { $User }

# Si no se proporcionó password, usar variable de entorno automáticamente
if (-not $Password) {
  $envPw = $env:GITEA_BOOTSTRAP_RUNNER_PASSWORD
  if ($envPw) { 
    $Password = ConvertTo-SecureString -String $envPw -AsPlainText -Force 
  } else {
    throw 'Debe proveer -Password o configurar GITEA_BOOTSTRAP_RUNNER_PASSWORD'
  }
}

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) { throw 'Se requieren privilegios de administrador.' }

$u = Get-LocalUser -Name $User -ErrorAction SilentlyContinue
if ($null -eq $u) { throw "Usuario no existe: $User (ejecute 200-create-runner-user.ps1)" }
Set-LocalUser -Name $User -Password $Password


Write-ScriptLog -Type 'End' -StartTime $scriptTimer





