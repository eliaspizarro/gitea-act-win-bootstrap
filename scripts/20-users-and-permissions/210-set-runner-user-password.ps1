param(
  [string]$User = 'gitea-runner',
  [SecureString]$Password,
  [switch]$FromEnv
)
$ErrorActionPreference = 'Stop'

# Priorizar variables de entorno para ejecución desatendida
$User = if ($env:GITEA_BOOTSTRAP_USER) { $env:GITEA_BOOTSTRAP_USER } else { $User }
if ($FromEnv -and -not $Password) {
  $envPw = $env:GITEA_BOOTSTRAP_RUNNER_PASSWORD
  if ($envPw) { $Password = ConvertTo-SecureString -String $envPw -AsPlainText -Force }
}
if (-not $Password) { throw 'Debe proveer -Password o -FromEnv con GITEA_BOOTSTRAP_RUNNER_PASSWORD' }

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) { throw 'Se requieren privilegios de administrador.' }

$u = Get-LocalUser -Name $User -ErrorAction SilentlyContinue
if ($null -eq $u) { throw "Usuario no existe: $User (ejecute 200-create-runner-user.ps1)" }
Set-LocalUser -Name $User -Password $Password
