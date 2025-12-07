param(
  [int]$OlderThanDays = 7
)
$ErrorActionPreference = 'Stop'
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
          # Eliminar carpetas vacías o antiguas
          $ageOk = ($_.LastWriteTime -lt $limit)
          if ($ageOk) { Remove-Item -LiteralPath $_.FullName -Recurse -Force -ErrorAction SilentlyContinue }
        }
        else {
          if ($_.LastWriteTime -lt $limit) { Remove-Item -LiteralPath $_.FullName -Force -ErrorAction SilentlyContinue }
        }
      } catch {}
    }
  } catch {}
}
