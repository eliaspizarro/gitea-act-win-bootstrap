param(
  [string]$GiteaServerUrl = 'https://TU_GITEA',
  [string]$GiteaRunnerToken = '${GITEA_RUNNER_TOKEN}',
  [string]$RunnerName = '${RUNNER_NAME}',
  [string]$RunnerLabels = 'windows,core,win2025',
  [string]$RunnerWorkDir = 'C:\Tools\gitea-act-runner\work',
  [int]$RunnerConcurrency = 1
)
$ErrorActionPreference = 'Stop'

function Set-Env([string]$Name, [string]$Value) {
  try {
    [Environment]::SetEnvironmentVariable($Name, $Value, 'Machine')
  } catch {
    [Environment]::SetEnvironmentVariable($Name, $Value, 'User')
  }
  Set-Item -Path "Env:$Name" -Value $Value | Out-Null
}

Set-Env -Name 'GITEA_SERVER_URL' -Value $GiteaServerUrl
Set-Env -Name 'GITEA_RUNNER_TOKEN' -Value $GiteaRunnerToken
Set-Env -Name 'RUNNER_NAME' -Value $RunnerName
Set-Env -Name 'RUNNER_LABELS' -Value $RunnerLabels
Set-Env -Name 'RUNNER_WORKDIR' -Value $RunnerWorkDir
Set-Env -Name 'RUNNER_CONCURRENCY' -Value ($RunnerConcurrency.ToString())
