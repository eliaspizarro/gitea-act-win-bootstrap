param(
  [string]$User = 'gitea-runner'
)
$ErrorActionPreference = 'Stop'

# Priorizar variables de entorno para ejecución desatendida
$User = if ($env:GITEA_BOOTSTRAP_USER -and $env:GITEA_BOOTSTRAP_USER -ne '') { $env:GITEA_BOOTSTRAP_USER } else { $User }

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) { throw 'Se requieren privilegios de administrador.' }

$acct = "$env:COMPUTERNAME\$User"
$tmp = Join-Path $env:TEMP ("secedit_" + [Guid]::NewGuid().ToString('N'))
$inf = "$tmp.inf"
$sdb = "$tmp.sdb"
New-Item -ItemType Directory -Path $tmp -Force | Out-Null

secedit /export /cfg $inf /quiet | Out-Null
$content = Get-Content -Path $inf -Raw
$line = ($content -split "`r?`n") | Where-Object { $_ -match '^SeServiceLogonRight\s*=\s*' } | Select-Object -First 1
if (-not $line) {
  Add-Content -Path $inf -Value "SeServiceLogonRight = $acct"
}
else {
  if ($line -notmatch [Regex]::Escape($acct)) {
    $newLine = if ($line.TrimEnd().EndsWith('=')) { "SeServiceLogonRight = $acct" } else { $line.TrimEnd() + ",$acct" }
    (Get-Content -Path $inf) | ForEach-Object {
      if ($_ -match '^SeServiceLogonRight\s*=\s*') { $newLine } else { $_ }
    } | Set-Content -Path $inf -Encoding ASCII
  }
}

secedit /configure /db $sdb /cfg $inf /quiet | Out-Null

Remove-Item -Recurse -Force -Path $tmp -ErrorAction SilentlyContinue | Out-Null
