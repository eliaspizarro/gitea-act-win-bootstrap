# Importar funciones de logging estandarizado
. "D:\Develop\personal\gitea-act-win-bootstrap\scripts\00-bootstrap\..\00-bootstrap\logging.ps1"

$scriptTimer = Start-ScriptTimer
Write-ScriptLog -Type 'Start'

param(
  [string]$TimeZone = 'UTC',
  [string]$SystemLocale,
  [string]$UserLocale,
  [string]$InputLocale
)
$ErrorActionPreference = 'Stop'
# Priorizar variables de entorno para ejecuciÃ³n desatendida
$TimeZone = if ($env:GITEA_BOOTSTRAP_TIMEZONE -and $env:GITEA_BOOTSTRAP_TIMEZONE -ne '') { $env:GITEA_BOOTSTRAP_TIMEZONE } else { $TimeZone }
$SystemLocale = if ($env:GITEA_BOOTSTRAP_SYSTEM_LOCALE -and $env:GITEA_BOOTSTRAP_SYSTEM_LOCALE -ne '') { $env:GITEA_BOOTSTRAP_SYSTEM_LOCALE } else { $SystemLocale }
$UserLocale = if ($env:GITEA_BOOTSTRAP_USER_LOCALE -and $env:GITEA_BOOTSTRAP_USER_LOCALE -ne '') { $env:GITEA_BOOTSTRAP_USER_LOCALE } else { $UserLocale }
$InputLocale = if ($env:GITEA_BOOTSTRAP_INPUT_LOCALE -and $env:GITEA_BOOTSTRAP_INPUT_LOCALE -ne '') { $env:GITEA_BOOTSTRAP_INPUT_LOCALE } else { $InputLocale }

try { tzutil /s $TimeZone | Out-Null } catch {}
if ($SystemLocale) { try { Set-WinSystemLocale -SystemLocale $SystemLocale } catch {} }
if ($UserLocale) { try { Set-Culture -CultureInfo $UserLocale } catch {} }
if ($InputLocale) { try { Set-WinUserLanguageList -LanguageList $InputLocale -Force | Out-Null } catch {} }


