# Activación y limitaciones

## Formas de activación admitidas
- KMS (recomendado en entornos corporativos).
- MAK (clave por equipo). Nunca almacenes la clave en el repositorio.

## Script de activación
- Ver estado:
  - `powershell -File scripts/10-os-config/170-windows-activation.ps1 -CheckOnly`
- Activar con clave (MAK):
  - `powershell -File scripts/10-os-config/170-windows-activation.ps1 -ProductKey (Read-Host 'Key' -AsSecureString)`

Notas del script:
- Usa `slmgr.vbs /dli`, `/ipk`, `/ato`.
- La clave se recibe como `SecureString`. Evita registrar la clave en logs o variables de texto plano.

## Seguridad de la clave
- No comitees claves ni tokens.
- Usa variables de entorno seguras o un almacén secreto (ej. kv/vault) para inyección temporal.

## Limitaciones conocidas
- Windows Core/Server Core: sin GUI; todo debe ejecutarse en PowerShell/CLI.
- Ediciones de evaluación expiran; `-CheckOnly` ayuda a monitorear el estado.
- Activación requiere conectividad (para KMS/MAK online); en entornos aislados, considera activación offline.

## Recomendaciones
- Automatiza `-CheckOnly` en mantenimiento para alertas tempranas.
- Documenta el origen KMS/MAK y ventanas de renovación.

