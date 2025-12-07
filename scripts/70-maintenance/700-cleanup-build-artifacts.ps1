param(
  [string[]]$Paths = @('C:\CI','C:\Logs','C:\Tools\gitea-act-runner'),
  [int]$OlderThanDays = 14
)
$ErrorActionPreference = 'Stop'
$limit = (Get-Date).AddDays(-$OlderThanDays)
foreach ($p in $Paths) {
  if (-not (Test-Path -LiteralPath $p)) { continue }
  Get-ChildItem -Path $p -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { $_.LastWriteTime -lt $limit } |
    ForEach-Object {
      try { Remove-Item -LiteralPath $_.FullName -Force -ErrorAction Stop } catch {}
    }
}
