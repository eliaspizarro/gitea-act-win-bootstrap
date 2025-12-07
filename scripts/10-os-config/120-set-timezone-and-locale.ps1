param(
  [string]$TimeZone = 'UTC',
  [string]$SystemLocale,
  [string]$UserLocale,
  [string]$InputLocale
)
$ErrorActionPreference = 'Stop'
try { tzutil /s $TimeZone | Out-Null } catch {}
if ($SystemLocale) { try { Set-WinSystemLocale -SystemLocale $SystemLocale } catch {} }
if ($UserLocale) { try { Set-Culture -CultureInfo $UserLocale } catch {} }
if ($InputLocale) { try { Set-WinUserLanguageList -LanguageList $InputLocale -Force | Out-Null } catch {} }
