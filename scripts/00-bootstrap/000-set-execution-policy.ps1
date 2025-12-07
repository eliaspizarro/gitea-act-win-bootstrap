$ErrorActionPreference = 'Stop'

try {
  $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
  $desired = 'RemoteSigned'
  $scopes = if ($isAdmin) { @('LocalMachine','CurrentUser') } else { @('CurrentUser') }

  foreach ($scope in $scopes) {
    $current = Get-ExecutionPolicy -Scope $scope -ErrorAction SilentlyContinue
    if ($current -ne $desired) {
      Set-ExecutionPolicy -Scope $scope -ExecutionPolicy $desired -Force
    }
  }

  exit 0
}
catch {
  Write-Error $_
  exit 1
}

