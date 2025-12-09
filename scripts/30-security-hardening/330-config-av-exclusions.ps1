param(
  [string[]]$Paths = @()  # Se construira con variables de entorno
)

# Importar funciones de logging estandarizado
. "$PSScriptRoot\..\lib\logging.ps1"

$scriptTimer = Start-ScriptTimer
Write-ScriptLog -Type 'Start'
$ErrorActionPreference = 'Stop'

# Construir rutas con variables de entorno
$ciDir = if ($env:GITEA_BOOTSTRAP_PROFILE_BASE_DIR) { $env:GITEA_BOOTSTRAP_PROFILE_BASE_DIR } else { 'C:\CI' }
$installDir = if ($env:GITEA_BOOTSTRAP_INSTALL_DIR) { $env:GITEA_BOOTSTRAP_INSTALL_DIR } else { 'C:\Tools' }
$logDir = if ($env:GITEA_BOOTSTRAP_LOG_DIR) { $env:GITEA_BOOTSTRAP_LOG_DIR } else { 'C:\Logs' }
$runnerDir = Join-Path $installDir 'gitea-act-runner'

# Priorizar variables de entorno para ejecución desatendida
if ($env:GITEA_BOOTSTRAP_AV_EXCLUSIONS -and $env:GITEA_BOOTSTRAP_AV_EXCLUSIONS -ne '') {
  # Resolver nombres de variables de entorno dinámicamente
  $envVarNames = $env:GITEA_BOOTSTRAP_AV_EXCLUSIONS.Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ }
  $resolvedPaths = @()
  
  foreach ($varName in $envVarNames) {
    $envValue = Get-Item -Path "Env:$varName" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Value
    if ($envValue -and $envValue -ne '') {
      $resolvedPaths += $envValue
    }
  }
  
  if ($resolvedPaths.Count -gt 0) {
    $Paths = $resolvedPaths
    Write-Host "Exclusiones AV resueltas desde variables: $($resolvedPaths -join ', ')" -ForegroundColor Green
  }
}

# Usar rutas con variables de entorno o valores por defecto
if ($Paths.Count -eq 0) {
  $Paths = @($ciDir, $installDir, $logDir, $runnerDir)
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



