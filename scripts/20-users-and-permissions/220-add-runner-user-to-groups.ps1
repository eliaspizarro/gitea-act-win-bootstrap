param(
  [string]$User = 'gitea-runner',
  [string[]]$Groups = @('Users', 'Performance Log Users')
)

# Importar funciones de logging estandarizado
. "$PSScriptRoot\..\lib\logging.ps1"

$scriptTimer = Start-ScriptTimer
Write-ScriptLog -Type 'Start'
$ErrorActionPreference = 'Stop'

# Priorizar variables de entorno para ejecución desatendida
$User = if ($env:GITEA_BOOTSTRAP_USER -and $env:GITEA_BOOTSTRAP_USER -ne '') { $env:GITEA_BOOTSTRAP_USER } else { $User }
if ($env:GITEA_BOOTSTRAP_USER_GROUPS -and $env:GITEA_BOOTSTRAP_USER_GROUPS -ne '') {
  $Groups = $env:GITEA_BOOTSTRAP_USER_GROUPS.Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ }
}

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) { throw 'Se requieren privilegios de administrador.' }
$u = Get-LocalUser -Name $User -ErrorAction SilentlyContinue
if ($null -eq $u) { throw "Usuario no existe: $User (ejecute 200-create-runner-user.ps1)" }
foreach ($g in $Groups) {
  $lg = Get-LocalGroup -Name $g -ErrorAction SilentlyContinue
  if ($null -eq $lg) { continue }
  try { Add-LocalGroupMember -Group $g -Member $User -ErrorAction SilentlyContinue } catch {}
}

Write-ScriptLog -Type 'End' -StartTime $scriptTimer

