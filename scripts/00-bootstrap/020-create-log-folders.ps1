# Importar funciones de logging estandarizado
. "$PSScriptRoot\logging.ps1"

$scriptTimer = Start-ScriptTimer
Write-ScriptLog -Type 'Start'

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

  Write-ScriptLog -Type 'End' -StartTime $scriptTimer
  exit 0
}
catch {
  Write-ScriptLog -Type 'Error' -Message $_.Exception.Message
  Write-Error $_
  exit 1
}


