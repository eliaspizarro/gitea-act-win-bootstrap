param(
  [string[]]$Paths = @('C:\CI','C:\Tools','C:\Logs','C:\Tools\gitea-act-runner'),
  [switch]$DisableRealtime
)

# Importar funciones de logging estandarizado
. "$PSScriptRoot\..\lib\logging.ps1"

$scriptTimer = Start-ScriptTimer
Write-ScriptLog -Type 'Start'
$ErrorActionPreference = 'Stop'

# Priorizar variables de entorno para ejecución desatendida
$InstallDir = if ($env:GITEA_BOOTSTRAP_INSTALL_DIR) { 
  $env:GITEA_BOOTSTRAP_INSTALL_DIR
} else { 
  'C:\Tools'
}
$RunnerDir = Join-Path $InstallDir 'gitea-act-runner'

if ($env:GITEA_BOOTSTRAP_AV_EXCLUSIONS -and $env:GITEA_BOOTSTRAP_AV_EXCLUSIONS -ne '') {
  $Paths = $env:GITEA_BOOTSTRAP_AV_EXCLUSIONS.Split(';') | ForEach-Object { $_.Trim() } | Where-Object { $_ }
} else {
  # Usar rutas dinámicas basadas en GITEA_BOOTSTRAP_INSTALL_DIR
  $Paths = @('C:\CI',$InstallDir,'C:\Logs',$RunnerDir)
}

$hasDefender = Get-Command Add-MpPreference -ErrorAction SilentlyContinue
if ($null -eq $hasDefender) { return }
if ($Paths) {
  $current = (Get-MpPreference).ExclusionPath
  foreach ($p in $Paths) {
    if (-not ($current -contains $p)) { Add-MpPreference -ExclusionPath $p }
  }
}
if ($DisableRealtime) { Set-MpPreference -DisableRealtimeMonitoring $true }


Write-ScriptLog -Type 'End' -StartTime $scriptTimer



