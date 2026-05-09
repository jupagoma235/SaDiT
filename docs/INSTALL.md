# Guía de Instalación — SaDiT

## Requisitos Previos

- Windows 10/11
- PowerShell 5.1+
- Conexión a internet (para descargar dependencias)

## Instalación

```powershell
# 1. Clonar el repositorio
git clone https://github.com/tuusuario/SaDiT.git
cd SaDiT

# 2. Ejecutar el instalador (como administrador)
.\setup.ps1

# 3. El instalador te preguntará:
#    - Ruta del vault Obsidian (default: %USERPROFILE%\SaDiTVault)
#    - Ruta de backup (default: D:\SaDiT_Backup)
#    - Nombre del proyecto activo
```

## Post-instalación

### 1. Programar backup automático
```powershell
.\src\scripts\programar-backup.ps1
```

### 2. Iniciar primera sesión
```powershell
.\src\scripts\iniciar-sesion.ps1
# Copia el prompt generado y pégalo en tu agente IA
```

### 3. Abrir en Obsidian
- Abre Obsidian
- "Abrir vault como carpeta"
- Selecciona la ruta del vault

## Instalación Manual

Si el instalador falla, hazlo paso a paso:

1. Instala SQLite: `winget install SQLite.SQLite`
2. Crea el vault: `mkdir %USERPROFILE%\SaDiTVault`
3. Copia templates: `copy src\vault\* %USERPROFILE%\SaDiTVault\`
4. Inicializa BD: `sqlite3 %USERPROFILE%\SaDiTVault\memoria_sadit.db < src\bd\schema.sql`
5. Inserta contexto: `sqlite3 %USERPROFILE%\SaDiTVault\memoria_sadit.db "INSERT INTO contexto_activo ..."`
