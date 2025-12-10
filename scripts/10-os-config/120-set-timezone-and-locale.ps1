param(
  [string]$TimeZone = 'UTC',
  [string]$SystemLocale,
  [string]$UserLocale,
  [string]$InputLocale,
  [string]$NTPServer = 'ntp.shoa.cl'
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
$NTPServer = if ($env:GITEA_BOOTSTRAP_NTP_SERVER -and $env:GITEA_BOOTSTRAP_NTP_SERVER -ne '') { $env:GITEA_BOOTSTRAP_NTP_SERVER } else { $NTPServer }

try { tzutil /s $TimeZone | Out-Null } catch {}
if ($SystemLocale) { try { Set-WinSystemLocale -SystemLocale $SystemLocale } catch {} }
if ($UserLocale) { try { Set-Culture -CultureInfo $UserLocale } catch {} }
if ($InputLocale) { try { Set-WinUserLanguageList -LanguageList $InputLocale -Force | Out-Null } catch {} }

# Configurar servidor NTP y sincronizar hora
if ($NTPServer) {
    try {
        Write-Host "Configurando servidor NTP: $NTPServer"
        # Configurar servidor NTP
        w32tm /config /manualpeerlist:"$NTPServer" /syncfromflags:manual /reliable:no /update | Out-Null
        
        # Reiniciar servicio de tiempo de Windows
        Restart-Service -Name "W32Time" -Force -ErrorAction SilentlyContinue
        
        # Forzar sincronización inmediata
        w32tm /resync /force | Out-Null
        
        # Verificar estado de sincronización
        $syncStatus = w32tm /query /status
        Write-Host "Estado de sincronizacion NTP:"
        $syncStatus
        
        Write-Host "Sincronizacion NTP completada exitosamente"
    }
    catch {
        Write-Warning "Error al configurar servidor NTP: $_"
    }
}

Write-ScriptLog -Type 'End' -StartTime $scriptTimer

