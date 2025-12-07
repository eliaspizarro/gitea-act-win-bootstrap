# Importar funciones de logging estandarizado
. "D:\Develop\personal\gitea-act-win-bootstrap\scripts\00-bootstrap\..\00-bootstrap\logging.ps1"

$scriptTimer = Start-ScriptTimer
Write-ScriptLog -Type 'Start'

param(
  [int]$OlderThanDays = 7
)
$ErrorActionPreference = 'Stop'

# Priorizar variables de entorno para ejecuciÃ³n desatendida
if ($env:GITEA_BOOTSTRAP_TEMP_CLEANUP_OLDER_THAN_DAYS -and $env:GITEA_BOOTSTRAP_TEMP_CLEANUP_OLDER_THAN_DAYS -ne '') {
  $OlderThanDays = [int]$env:GITEA_BOOTSTRAP_TEMP_CLEANUP_OLDER_THAN_DAYS
}

$limit = (Get-Date).AddDays(-$OlderThanDays)
$targets = @()
$targets += $env:TEMP
$targets += 'C:\Windows\Temp'
$targets = $targets | Where-Object { $_ -and (Test-Path -LiteralPath $_) } | Select-Object -Unique
foreach ($t in $targets) {
  try {
    Get-ChildItem -Path $t -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
      try {
        if ($_.PSIsContainer) {
          # Eliminar carpetas vacÃ­as o antiguas
          $ageOk = ($_.LastWriteTime -lt $limit)
          if ($ageOk) { Remove-Item -LiteralPath $_.FullName -Recurse -Force -ErrorAction SilentlyContinue }
  Write-ScriptLog -Type 'End' -StartTime $scriptTimer
        }
        else {
          if ($_.LastWriteTime -lt $limit) { Remove-Item -LiteralPath $_.FullName -Force -ErrorAction SilentlyContinue }
  Write-ScriptLog -Type 'End' -StartTime $scriptTimer
        }
  Write-ScriptLog -Type 'End' -StartTime $scriptTimer
      } catch {}
  Write-ScriptLog -Type 'End' -StartTime $scriptTimer
    }
  Write-ScriptLog -Type 'End' -StartTime $scriptTimer
  } catch {}
  Write-ScriptLog -Type 'End' -StartTime $scriptTimer
}


