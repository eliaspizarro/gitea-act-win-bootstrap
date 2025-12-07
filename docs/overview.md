# Overview

Este repositorio automatiza el bootstrap de un runner de Gitea `act_runner` en Windows (Server Core / Windows 10/11/Server) de forma 100% headless, usando PowerShell y Chocolatey.

## Objetivos
- Preparar el SO para CI (energía, hibernación, rutas largas, timezone, pagefile, temp, features).
- Instalar toolchain de build (Chocolatey, 7-Zip CLI, .NET SDK LTS, Node.js v24, Git, VS Build Tools, Windows SDK).
- Instalar y configurar `act_runner` con YAML generado desde variables de entorno.
- Registrar inicio automático mediante Tarea Programada.

## Prerrequisitos
- Ejecutar PowerShell como Administrador para pasos de sistema.
- Conectividad a `community.chocolatey.org` y fuentes de Microsoft/Gitea.
- Clave de activación (opcional), y URL/token de Gitea (necesarios para el runner).

## Orden recomendado de ejecución
1. scripts/00-bootstrap/*
2. scripts/10-os-config/* (incluye 115 rutas largas y 170 activación opcional)
3. scripts/40-system-tools/*
4. scripts/50-build-toolchain/*
5. configs/set-env.sample.ps1 (establecer variables)
6. scripts/60-gitea-act-runner/*
7. scripts/30-security-hardening/* (opcional según políticas)
8. scripts/70-maintenance/* (según necesidad)

## Flujo resumido
1) Bootstrap y config SO.
2) Instalar herramientas vía Chocolatey.
3) Definir variables con `configs/set-env.sample.ps1`.
4) Generar YAML con `scripts/60-gitea-act-runner/630-config-act-runner-yaml.ps1`.
5) Crear script de arranque y registrar tarea (610 y 620).

## Variables de entorno clave
- `GITEA_SERVER_URL`: URL del servidor Gitea.
- `GITEA_RUNNER_TOKEN`: token del runner (no se guarda en el repo).
- `RUNNER_NAME`: nombre del runner.
- `RUNNER_LABELS`: etiquetas separadas por coma.
- `RUNNER_WORKDIR`: directorio de trabajo del runner.
- `RUNNER_CONCURRENCY`: concurrencia del runner.

Se establecen con `configs/set-env.sample.ps1` y se consumen al generar el YAML del runner.

## Rutas e instaladores
- `C:\Tools\gitea-act-runner`: binarios y config del runner.
- `C:\Logs\ActRunner`: logs de ejecución.
- Instalación de herramientas exclusivamente en modo CLI (sin GUI).

