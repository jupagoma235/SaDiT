# Arquitectura de SaDiT

## Visión General

SaDiT es un sistema de **memoria dual** para asistentes IA locales:

```
Agente IA (OpenCode, etc.)
    │
    ├── Memoria Narrativa (Obsidian Vault)
    │   ├── _index.md              → Contexto de arranque
    │   ├── _prompt-inicial.md     → Instrucciones para el agente
    │   ├── _plan-recuperacion.md  → Plan de disaster recovery
    │   └── [proyecto]/            → Notas por proyecto
    │
    └── Memoria Estructurada (SQLite)
        ├── sesiones               → Registro de conversaciones
        ├── aprendizajes           → Hechos reutilizables
        ├── logs_conversacion      → Historial de mensajes
        ├── proyectos              → Catálogo de proyectos
        ├── config_sistema         → Snapshots de configuración
        └── contexto_activo        → Variables vigentes
```

## Componentes

| Componente | Rol | Dependencia |
|---|---|---|
| Obsidian | UI para notas humanas | Ninguna |
| SQLite | BD embebida para IA | sqlite3.exe |
| PowerShell | Automatización del sistema | Windows |
| Ollama (opcional) | Inferencia IA local | GPU/RAM |

## Flujo de una Sesión

1. Usuario ejecuta `iniciar-sesion.ps1`
2. Script crea sesión en BD y genera prompt con contexto
3. Usuario pega prompt al agente IA
4. Agente carga contexto (vault + BD)
5. Durante la interacción, agente registra logs y aprendizajes
6. Al cerrar, agente actualiza resumen de sesión

## Backup y Recuperación

- Backup semanal automático (domingos 10:00)
- Contenido: vault completo + dump SQL de BD
- Destino configurable (default: D:\SaDiT_Backup)
- Recuperación: ejecutar `restaurar.ps1` (~20 min)
