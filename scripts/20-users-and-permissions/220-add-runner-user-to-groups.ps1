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

$sidMap = @{
  'administrators'                 = 'S-1-5-32-544'
  'administradores'                = 'S-1-5-32-544'
  'users'                          = 'S-1-5-32-545'
  'usuarios'                       = 'S-1-5-32-545'
  'performance log users'          = 'S-1-5-32-559'
  'usuarios del registro de rendimiento' = 'S-1-5-32-559'
  'remote desktop users'           = 'S-1-5-32-555'
  'usuarios de escritorio remoto'  = 'S-1-5-32-555'
  'distributed com users'          = 'S-1-5-32-562'
  'usuarios com distribuidos'      = 'S-1-5-32-562'
}

function Resolve-GroupToken {
  param([string]$Token)
  if (-not $Token) { return $null }
  $t = $Token.Trim()
  if (-not $t) { return $null }
  # Si es SID directamente, traducir a nombre local
  if ($t -match '^(S-\d(-\d+){1,})$') {
    try {
      $acc = ([System.Security.Principal.SecurityIdentifier]$t).Translate([System.Security.Principal.NTAccount])
      return ($acc.Value.Split('\\')[-1])
    } catch { return $null }
  }
  # Mapear alias conocidos (independiente de idioma) a SID y luego traducir
  $key = $t.ToLower()
  if ($sidMap.ContainsKey($key)) {
    try {
      $acc = ([System.Security.Principal.SecurityIdentifier]$sidMap[$key]).Translate([System.Security.Principal.NTAccount])
      return ($acc.Value.Split('\\')[-1])
    } catch { return $null }
  }
  # Intentar usar el nombre tal cual si existe localmente
  try {
    $lg = Get-LocalGroup -Name $t -ErrorAction Stop
    if ($lg) { return $t }
  } catch {}
  return $null
}

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) { throw 'Se requieren privilegios de administrador.' }
$u = Get-LocalUser -Name $User -ErrorAction SilentlyContinue
if ($null -eq $u) { throw "Usuario no existe: $User (ejecute 200-create-runner-user.ps1)" }
foreach ($g in ($Groups | Select-Object -Unique)) {
  $resolved = Resolve-GroupToken -Token $g
  if (-not $resolved) { continue }
  try { Add-LocalGroupMember -Group $resolved -Member $User -ErrorAction SilentlyContinue } catch {}
}

Write-ScriptLog -Type 'End' -StartTime $scriptTimer

