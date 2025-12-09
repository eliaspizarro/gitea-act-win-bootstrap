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

# Definición de mapeo de grupos (nombres -> SSID)
$groupMappings = @(
  @(@('administrators', 'administradores'), 'S-1-5-32-544'),
  @(@('users', 'usuarios'), 'S-1-5-32-545'),
  @(@('guests', 'invitados'), 'S-1-5-32-546'),
  @(@('power users', 'usuarios avanzados'), 'S-1-5-32-547'),
  @(@('print operators', 'opers. de impresión'), 'S-1-5-32-550'),
  @(@('backup operators', 'operadores de copia de seguridad'), 'S-1-5-32-551'),
  @(@('replicators', 'duplicadores'), 'S-1-5-32-552'),
  @(@('network configuration operators', 'operadores de configuración de red'), 'S-1-5-32-556'),
  @(@('system monitor users', 'usuarios del monitor de sistema'), 'S-1-5-32-558'),
  @(@('performance log users', 'usuarios del registro de rendimiento'), 'S-1-5-32-559'),
  @(@('distributed com users', 'usuarios com distribuidos'), 'S-1-5-32-562'),
  @(@('iis_iusrs'), 'S-1-5-32-568'),
  @(@('event log readers', 'lectores del registro de eventos'), 'S-1-5-32-573'),
  @(@('certificate service dcom access', 'acceso dcom a serv. de certif.'), 'S-1-5-32-574'),
  @(@('cryptographic operators', 'operadores criptográficos'), 'S-1-5-32-569'),
  @(@('rds remote access servers', 'servidores de acceso remoto rds'), 'S-1-5-32-575'),
  @(@('rds endpoint servers', 'servidores de extremo rds'), 'S-1-5-32-576'),
  @(@('rds management servers', 'servidores de administración rds'), 'S-1-5-32-577'),
  @(@('hyper-v administrators', 'administradores de hyper-v'), 'S-1-5-32-578'),
  @(@('access control assistance operators', 'operadores de asistencia de control de acceso'), 'S-1-5-32-579'),
  @(@('remote management users', 'usuarios de administración remota'), 'S-1-5-32-580'),
  @(@('remote desktop users', 'usuarios de escritorio remoto'), 'S-1-5-32-555'),
  @(@('openssh users', 'usuarios de openssh'), 'S-1-5-32-585'),
  @(@('device owners', 'propietarios del dispositivo'), 'S-1-5-32-583'),
  @(@('user mode hardware operators', 'operadores de hardware en modo usuario'), 'S-1-5-32-584'),
  @(@('storage replica administrators'), 'S-1-5-32-582'),
  @(@('system managed accounts group'), 'S-1-5-32-581')
)

# Generar hash table plano para lookups eficientes
$sidMap = @{}
foreach ($mapping in $groupMappings) {
  $names = $mapping[0]
  $sid = $mapping[1]
  foreach ($name in $names) {
    $sidMap[$name.ToLower()] = $sid
  }
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

