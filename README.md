# SaDiT — Sistema de Asistencia y Documentación Inteligente en Terminal

**Entorno IA local con memoria dual: narrativa (Obsidian) + estructurada (SQLite).**

SaDiT es un sistema portable que permite a cualquier agente de IA (OpenCode, etc.) operar con **contexto persistente**, **memoria a largo plazo** y **capacidad de recuperación total** — todo local, sin depender de la nube.

## Requisitos

| Componente | Mínimo | Recomendado |
|---|---|---|
| Sistema operativo | Windows 10 | Windows 11 |
| RAM | 8 GB | 16 GB+ |
| Disco | 10 GB libres | 30 GB+ (para modelos IA) |
| Python | 3.10+ | 3.14+ |
| Ollama | 0.20+ | 0.23+ |

## Instalación Rápida

```powershell
# 1. Clonar el repositorio
git clone https://github.com/tuusuario/SaDiT.git
cd SaDiT

# 2. Ejecutar el instalador
.\setup.ps1

# El instalador te guiará por:
#   - Instalación de dependencias (SQLite, Python, etc.)
#   - Configuración del vault de Obsidian
#   - Inicialización de la base de datos
#   - Configuración de backup automático
```

## Estructura del Repositorio

```
SaDiT/
├── setup.ps1                   ← Instalador principal
├── config/
│   ├── config.ps1              ← Template de configuración
│   └── config.json.example     ← Configuración del sistema
├── src/
│   ├── scripts/
│   │   ├── iniciar-sesion.ps1  ← Inicia sesión con contexto completo
│   │   ├── respaldar.ps1       ← Backup del vault + BD
│   │   ├── restaurar.ps1       ← Restaura desde backup
│   │   └── programar-backup.ps1← Crea tarea programada
│   ├── vault/
│   │   ├── _index.md           ← Template del índice maestro
│   │   ├── _prompt-inicial.md  ← Prompt para agentes IA
│   │   ├── _plan-recuperacion.md
│   │   ├── _arquitectura/      ← Diagramas y documentación
│   │   └── proyecto-ejemplo/
│   └── bd/
│       └── schema.sql          ← Esquema de la base de datos
└── docs/
    ├── INSTALL.md              ← Guía de instalación detallada
    └── ARCHITECTURE.md         ← Visión general del sistema
```

## Concepto: Memoria Dual

```
┌─────────────────────────────────────────────────────┐
│                   SaDiT                              │
│  ┌─────────────────┐    ┌────────────────────────┐  │
│  │  Memoria         │    │  Memoria               │  │
│  │  Narrativa       │    │  Estructurada          │  │
│  │  (Obsidian)      │    │  (SQLite)              │  │
│  ├─────────────────┤    ├────────────────────────┤  │
│  │  Notas .md       │    │  aprendizajes          │  │
│  │  Documentación   │    │  sesiones              │  │
│  │  Contexto inicio │    │  logs_conversacion     │  │
│  │  Diagramas       │    │  contexto_activo       │  │
│  └─────────────────┘    └────────────────────────┘  │
└─────────────────────────────────────────────────────┘
```

## Licencia

MIT License — Copyright (c) 2026 jupagoma235

Ver archivo [LICENSE](LICENSE) para más detalles.
