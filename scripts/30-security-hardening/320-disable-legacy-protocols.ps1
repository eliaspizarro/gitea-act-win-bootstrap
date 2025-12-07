$ErrorActionPreference = 'Stop'

# Deshabilitar SMBv1
try { Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force | Out-Null } catch {}
try { Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart -ErrorAction SilentlyContinue | Out-Null } catch {}

# SCHANNEL: deshabilitar TLS 1.0/1.1 y habilitar TLS 1.2/1.3
$base = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols'
$items = @(
  @{ Proto = 'TLS 1.0'; Client = @{ DisabledByDefault = 1; Enabled = 0 }; Server = @{ DisabledByDefault = 1; Enabled = 0 } },
  @{ Proto = 'TLS 1.1'; Client = @{ DisabledByDefault = 1; Enabled = 0 }; Server = @{ DisabledByDefault = 1; Enabled = 0 } },
  @{ Proto = 'TLS 1.2'; Client = @{ DisabledByDefault = 0; Enabled = 1 }; Server = @{ DisabledByDefault = 0; Enabled = 1 } },
  @{ Proto = 'TLS 1.3'; Client = @{ DisabledByDefault = 0; Enabled = 1 }; Server = @{ DisabledByDefault = 0; Enabled = 1 } }
)
foreach ($i in $items) {
  $c = Join-Path (Join-Path $base $i.Proto) 'Client'
  $s = Join-Path (Join-Path $base $i.Proto) 'Server'
  foreach ($p in @($c,$s)) { if (-not (Test-Path $p)) { New-Item -Path $p -Force | Out-Null } }
  foreach ($kv in $i.Client.GetEnumerator()) { New-ItemProperty -Path $c -Name $kv.Key -Value $kv.Value -PropertyType DWord -Force | Out-Null }
  foreach ($kv in $i.Server.GetEnumerator()) { New-ItemProperty -Path $s -Name $kv.Key -Value $kv.Value -PropertyType DWord -Force | Out-Null }
}
