# Índice Maestro — SaDiT

> **Versión:** 1.1.0
> **Generado por:** setup.ps1

## Arquitectura de Memoria

```
SaDiT
├── Obsidian Vault (narrativa) ← notas, contexto, documentación
└── SQLite (estructurada)      ← aprendizajes, sesiones, logs
```

## Instrucciones para el Agente

1. Leer `_prompt-inicial.md` para entender el sistema de memoria dual
2. Consultar la BD SQLite: contexto_activo y aprendizajes relevantes
3. Responder en el idioma configurado
4. Escribir en ambas memorias:
   - Notas .md para documentación legible
   - `aprendizajes` en BD para hechos reutilizables
   - `logs_conversacion` en BD para cada mensaje

## Proyecto activo

Configurado durante la instalación. Revisar `contexto_activo` en la BD.
