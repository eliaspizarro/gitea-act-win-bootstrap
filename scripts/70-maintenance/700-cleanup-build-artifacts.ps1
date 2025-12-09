param(
  [int]$OlderThanDays = 14,
  [string[]]$Paths = @()  # Se construirá con variables de entorno
)

# Importar funciones de logging estandarizado
. "$PSScriptRoot\..\lib\logging.ps1"

$scriptTimer = Start-ScriptTimer
Write-ScriptLog -Type 'Start'
$ErrorActionPreference = 'Stop'

# Construir rutas con variables de entorno
$logDir = if ($env:GITEA_BOOTSTRAP_LOG_DIR) { $env:GITEA_BOOTSTRAP_LOG_DIR } else { 'C:\Logs' }
$installDir = if ($env:GITEA_BOOTSTRAP_INSTALL_DIR) { 
  Join-Path $env:GITEA_BOOTSTRAP_INSTALL_DIR 'gitea-act-runner' 
} else { 
  'C:\Tools\gitea-act-runner' 
}
$ciDir = if ($env:GITEA_BOOTSTRAP_PROFILE_BASE_DIR) { $env:GITEA_BOOTSTRAP_PROFILE_BASE_DIR } else { 'C:\CI' }

# Usar rutas con variables de entorno o valores por defecto
if ($Paths.Count -eq 0) {
  $Paths = @($ciDir, $logDir, $installDir)
}
# Priorizar variables de entorno para ejecución desatendida
if ($env:GITEA_BOOTSTRAP_CLEANUP_PATHS -and $env:GITEA_BOOTSTRAP_CLEANUP_PATHS -ne '') {
  $Paths = $env:GITEA_BOOTSTRAP_CLEANUP_PATHS.Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ }
}
if ($env:GITEA_BOOTSTRAP_CLEANUP_OLDER_THAN_DAYS -and $env:GITEA_BOOTSTRAP_CLEANUP_OLDER_THAN_DAYS -ne '') {
  $OlderThanDays = [int]$env:GITEA_BOOTSTRAP_CLEANUP_OLDER_THAN_DAYS
}

$limit = (Get-Date).AddDays(-$OlderThanDays)
foreach ($p in $Paths) {
  if (-not (Test-Path -LiteralPath $p)) { continue }
  Get-ChildItem -Path $p -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { $_.LastWriteTime -lt $limit } |
    ForEach-Object {
      try { Remove-Item -LiteralPath $_.FullName -Force -ErrorAction Stop } catch {}
    }
}

Write-ScriptLog -Type 'End' -StartTime $scriptTimer




