# Arquitectura SaDiT — Visión General

## Diagrama de Contexto

```mermaid
graph TB
    subgraph "PC Local"
        IDE[IDE / Terminal]
        AGENTE[Agente IA<br/>OpenCode]
        VAULT[Obsidian Vault<br/>Memoria Narrativa]
        DB[(SQLite<br/>Memoria Estructurada)]
        OLLAMA[Ollama Server<br/>Modelos locales]
        BACKUP[Backup<br/>Disco externo]
    end

    USUARIO -->|interactúa| IDE
    IDE -->|ejecuta| AGENTE
    AGENTE -->|consulta| OLLAMA
    AGENTE -->|lee/escribe| VAULT
    AGENTE -->|SQL| DB
    BACKUP -.->|respalda| VAULT
    BACKUP -.->|respalda| DB
```

## Principios

1. **Local-first**: Todo corre en la PC, sin nube
2. **Dual-memory**: Dos sistemas de memoria complementarios
3. **Portable**: Configurable en cualquier PC via setup.ps1
4. **Recuperable**: Backup automático + plan de restauración
5. **Versionado**: Cambios trackeados con Git

## Archivos de Arquitectura

| Archivo | Contenido |
|---|---|
| `index.md` | Visión general |
| `01-memoria-dual.md` | Sistema de memoria dual |
| `02-flujo-sesion.md` | Ciclo de una sesión |
| `03-backup.md` | Estrategia de backup |
| `04-esquema-bd.md` | Modelo de base de datos |
