$ErrorActionPreference = 'Stop'

try {
  $paths = @(
    'C:\Logs',
    'C:\Logs\Bootstrap',
    'C:\Logs\PowerShell',
    'C:\Logs\ActRunner'
  )

  foreach ($p in $paths) {
    if (-not (Test-Path -LiteralPath $p)) {
      New-Item -ItemType Directory -Path $p -Force | Out-Null
    }
  }

  exit 0
}
catch {
  Write-Error $_
  exit 1
}

