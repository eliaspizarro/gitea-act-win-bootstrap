param(
  [string]$User = 'gitea-runner',
  [string[]]$Groups = @('Users', 'Performance Log Users')
)
$ErrorActionPreference = 'Stop'
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) { throw 'Se requieren privilegios de administrador.' }
$u = Get-LocalUser -Name $User -ErrorAction SilentlyContinue
if ($null -eq $u) { throw "Usuario no existe: $User (ejecute 200-create-runner-user.ps1)" }
foreach ($g in $Groups) {
  $lg = Get-LocalGroup -Name $g -ErrorAction SilentlyContinue
  if ($null -eq $lg) { continue }
  try { Add-LocalGroupMember -Group $g -Member $User -ErrorAction SilentlyContinue } catch {}
}
