param(
  [string]$TimeZone = 'UTC',
  [string]$SystemLocale,
  [string]$UserLocale,
  [string]$InputLocale
)

# Importar funciones de logging estandarizado
. "$PSScriptRoot\..\lib\logging.ps1"

$scriptTimer = Start-ScriptTimer
Write-ScriptLog -Type 'Start'
$ErrorActionPreference = 'Stop'
# Priorizar variables de entorno para ejecución desatendida
$TimeZone = if ($env:GITEA_BOOTSTRAP_TIMEZONE -and $env:GITEA_BOOTSTRAP_TIMEZONE -ne '') { $env:GITEA_BOOTSTRAP_TIMEZONE } else { $TimeZone }
$SystemLocale = if ($env:GITEA_BOOTSTRAP_SYSTEM_LOCALE -and $env:GITEA_BOOTSTRAP_SYSTEM_LOCALE -ne '') { $env:GITEA_BOOTSTRAP_SYSTEM_LOCALE } else { $SystemLocale }
$UserLocale = if ($env:GITEA_BOOTSTRAP_USER_LOCALE -and $env:GITEA_BOOTSTRAP_USER_LOCALE -ne '') { $env:GITEA_BOOTSTRAP_USER_LOCALE } else { $UserLocale }
$InputLocale = if ($env:GITEA_BOOTSTRAP_INPUT_LOCALE -and $env:GITEA_BOOTSTRAP_INPUT_LOCALE -ne '') { $env:GITEA_BOOTSTRAP_INPUT_LOCALE } else { $InputLocale }

try { tzutil /s $TimeZone | Out-Null } catch {}
if ($SystemLocale) { try { Set-WinSystemLocale -SystemLocale $SystemLocale } catch {} }
if ($UserLocale) { try { Set-Culture -CultureInfo $UserLocale } catch {} }
if ($InputLocale) { try { Set-WinUserLanguageList -LanguageList $InputLocale -Force | Out-Null } catch {} }

Write-ScriptLog -Type 'End' -StartTime $scriptTimer

