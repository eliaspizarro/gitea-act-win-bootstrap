$ErrorActionPreference = 'Stop'
try {
  powercfg -h off | Out-Null
} catch {}
try { powercfg /x standby-timeout-ac 0 | Out-Null } catch {}
try { powercfg /x standby-timeout-dc 0 | Out-Null } catch {}
