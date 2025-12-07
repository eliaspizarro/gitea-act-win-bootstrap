# Importar funciones de logging estandarizado
. "D:\Develop\personal\gitea-act-win-bootstrap\scripts\00-bootstrap\..\00-bootstrap\logging.ps1"

$scriptTimer = Start-ScriptTimer
Write-ScriptLog -Type 'Start'

param(
  [string[]]$Paths = @('C:\CI','C:\Logs','C:\Tools\gitea-act-runner'),
  [int]$OlderThanDays = 14
)
$ErrorActionPreference = 'Stop'

# Priorizar variables de entorno para ejecuciÃ³n desatendida
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
  Write-ScriptLog -Type 'End' -StartTime $scriptTimer
    }
  Write-ScriptLog -Type 'End' -StartTime $scriptTimer
}


