$ErrorActionPreference = 'Stop'
try { powercfg /SETACTIVE SCHEME_MAX | Out-Null } catch {}
