param(
  [string]$User = 'gitea-runner'
)
$ErrorActionPreference = 'Stop'

# Priorizar variable de entorno para ejecución desatendida
$User = if ($env:GITEA_BOOTSTRAP_USER) { $env:GITEA_BOOTSTRAP_USER } else { $User }

$u = Get-LocalUser -Name $User -ErrorAction SilentlyContinue
if ($null -eq $u) {
  $pw = ([Guid]::NewGuid().ToString('N') + 'aA1!')
  $sec = ConvertTo-SecureString -String $pw -AsPlainText -Force
  New-LocalUser -Name $User -Password $sec -PasswordNeverExpires:$true -AccountNeverExpires:$true | Out-Null
  Enable-LocalUser -Name $User | Out-Null
}
