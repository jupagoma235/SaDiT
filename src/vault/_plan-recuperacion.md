# Plan de Recuperación — SaDiT

## ¿Qué respaldar?

| Elemento | Se respalda |
|---|---|
| Vault (notas, prompts, scripts) | ✅ Backup automático |
| BD SQLite (aprendizajes, sesiones, logs) | ✅ Dump SQL + copia binaria |
| Configuración local | ✅ `config.local.ps1` |
| Modelos Ollama | ❌ Se redescargan |
| IDE | ❌ Se reinstala |

## Cómo restaurar

```powershell
# 1. Instalar dependencias mínimas
winget install SQLite.SQLite

# 2. Ejecutar el restaurador
.\src\scripts\restaurar.ps1

# 3. Abrir Obsidian → Abrir vault → %USERPROFILE%\SaDiTVault
```

## Backup automático

```powershell
.\src\scripts\programar-backup.ps1
# Crea tarea: SaDiT_Backup (domingos 10:00 AM)
```

## Tiempo estimado de recuperación
- ~20 minutos desde PC formateada hasta entorno operativo
