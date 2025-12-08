# Importar funciones de logging estandarizado
. "$PSScriptRoot\..\lib\logging.ps1"

$scriptTimer = Start-ScriptTimer
Write-ScriptLog -Type 'Start'

$ErrorActionPreference = 'Stop'

try {
  $base = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell'
  if (-not (Test-Path $base)) { New-Item -Path $base -Force | Out-Null }

  $sbl = Join-Path $base 'ScriptBlockLogging'
  if (-not (Test-Path $sbl)) { New-Item -Path $sbl -Force | Out-Null }
  New-ItemProperty -Path $sbl -Name 'EnableScriptBlockLogging' -Value 1 -PropertyType DWord -Force | Out-Null

  $ml = Join-Path $base 'ModuleLogging'
  if (-not (Test-Path $ml)) { New-Item -Path $ml -Force | Out-Null }
  New-ItemProperty -Path $ml -Name 'EnableModuleLogging' -Value 1 -PropertyType DWord -Force | Out-Null
  $mlk = Join-Path $ml 'ModuleNames'
  if (-not (Test-Path $mlk)) { New-Item -Path $mlk -Force | Out-Null }
  New-ItemProperty -Path $mlk -Name '*' -Value '*' -PropertyType String -Force | Out-Null

  exit 0
}
catch {
  Write-ScriptLog -Type 'Error' -Message $_.Exception.Message
  Write-Error $_
  exit 1
}

Write-ScriptLog -Type 'End' -StartTime $scriptTimer


