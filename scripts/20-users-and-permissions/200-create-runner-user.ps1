param(
  [string]$User = 'gitea-runner'
)
$ErrorActionPreference = 'Stop'
$u = Get-LocalUser -Name $User -ErrorAction SilentlyContinue
if ($null -eq $u) {
  $pw = ([Guid]::NewGuid().ToString('N') + 'aA1!')
  $sec = ConvertTo-SecureString -String $pw -AsPlainText -Force
  New-LocalUser -Name $User -Password $sec -PasswordNeverExpires:$true -AccountNeverExpires:$true | Out-Null
  Enable-LocalUser -Name $User | Out-Null
}
