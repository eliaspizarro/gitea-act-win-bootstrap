# Importar funciones de logging estandarizado
. "D:\Develop\personal\gitea-act-win-bootstrap\scripts\00-bootstrap\..\00-bootstrap\logging.ps1"

$scriptTimer = Start-ScriptTimer
Write-ScriptLog -Type 'Start'

$ErrorActionPreference = 'Stop'
$pol = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer'
if (-not (Test-Path $pol)) { New-Item -Path $pol -Force | Out-Null }
New-ItemProperty -Path $pol -Name 'Logging' -PropertyType String -Value 'voicewarmupx' -Force | Out-Null
$def = 'HKLM:\SOFTWARE\Microsoft\Windows\Installer'
if (-not (Test-Path $def)) { New-Item -Path $def -Force | Out-Null }
New-ItemProperty -Path $def -Name 'Logging' -PropertyType String -Value 'voicewarmupx' -Force | Out-Null


Write-ScriptLog -Type 'End' -StartTime $scriptTimer

