# Checklist de hardening (mínimo viable)

Use esta lista como verificación rápida. Todas las acciones son reversibles y están automatizadas por `scripts/30-security-hardening/*`.

## Sistema/Protocolo
- [ ] Deshabilitar SMBv1 (320): `Set-SmbServerConfiguration -EnableSMB1Protocol $false` y feature SMB1 off.
- [ ] Forzar TLS 1.2/1.3, deshabilitar TLS 1.0/1.1 (320): claves SCHANNEL aplicadas.
- [ ] .NET fuerte cifrado (300): `SchUseStrongCrypto=1` en 32/64 bits.

## Firewall/Red
- [ ] Perfilar Firewall activo (310): `Set-NetFirewallProfile ... -Enabled True`.
- [ ] WinRM solo si se requiere (310): regla HTTP-In habilitada u omitida.

## Antivirus/Exclusiones
- [ ] Definir exclusiones (330) para: `C:\\CI`, `C:\\Tools`, `C:\\Logs`, `C:\\Tools\\gitea-act-runner`.
- [ ] Evitar desactivar protección en tiempo real salvo casos puntuales.

## Servicios
- [ ] Deshabilitar servicios no requeridos (340): Fax, Xbox*, WSearch (si no se usa indexado local).

## Cuentas y permisos
- [ ] Usuario del runner sin privilegios elevados por defecto.
- [ ] Conceder `SeServiceLogonRight` si operará como servicio/tarea (240).
- [ ] ACLs correctas en `C:\\CI\\work` y `C:\\CI\\cache` (230).

## Registro/Logs
- [ ] Habilitar Script/Module Logging de PowerShell (010).
- [ ] Centralizar logs en `C:\\Logs\\*`.

## Validaciones rápidas
- [ ] `Get-SmbServerConfiguration | Select EnableSMB1Protocol` devuelve False.
- [ ] `reg query` de SCHANNEL muestra TLS 1.2/1.3 habilitado.
- [ ] `Get-MpPreference` refleja exclusiones esperadas.
- [ ] `Get-Service` muestra servicios deshabilitados según lo planificado.

