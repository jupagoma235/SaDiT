# ============================================================
# INSTALADOR DE SaDiT
# ============================================================
# Configura todo desde 0 en una PC nueva:
#   1. Verifica/instala dependencias
#   2. Pregunta rutas al usuario
#   3. Inicializa vault y BD
#   4. Configura backup
# ============================================================

# Auto-elevación
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path $PSCommandPath -Parent

Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   SaDiT — INSTALADOR                   ║" -ForegroundColor Cyan
Write-Host "║   Sistema de Asistencia y Doc. IA      ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# --- Paso 1: Dependencias ---
Write-Host "─── Paso 1: Dependencias ───" -ForegroundColor Yellow

# SQLite
$sqlite = Get-Command sqlite3 -ErrorAction SilentlyContinue
if (-not $sqlite) {
    Write-Host "  Instalando SQLite..."
    winget install -e --id SQLite.SQLite --accept-source-agreements --accept-package-agreements
    $sqlite = Get-Command sqlite3 -ErrorAction SilentlyContinue
}
if ($sqlite) { Write-Host "  [✓] SQLite: $(& $sqlite.Source --version)" -ForegroundColor Green }

# Git
$git = Get-Command git -ErrorAction SilentlyContinue
if (-not $git) {
    Write-Host "  Instalando Git..."
    winget install -e --id Git.Git --accept-source-agreements --accept-package-agreements
}
if ((Get-Command git -ErrorAction SilentlyContinue)) { Write-Host "  [✓] Git instalado" -ForegroundColor Green }

# Ollama (opcional)
$ollama = Get-Command ollama -ErrorAction SilentlyContinue
if (-not $ollama) {
    Write-Host "  [!] Ollama no encontrado. Descárgalo de https://ollama.com/download" -ForegroundColor Yellow
} else {
    Write-Host "  [✓] Ollama: $(& $ollama.Source --version)" -ForegroundColor Green
}

# --- Paso 2: Configurar rutas ---
Write-Host "`n─── Paso 2: Configuración ───" -ForegroundColor Yellow

$defaultVault = "$env:USERPROFILE\SaDiTVault"
$defaultBackup = "D:\SaDiT_Backup"
$readHost = {
    param($prompt, $default)
    $input = Read-Host "$prompt [$default]"
    if ([string]::IsNullOrWhiteSpace($input)) { $default } else { $input }
}

$vaultPath = & $readHost "  Ruta del vault Obsidian" $defaultVault
$backupPath = & $readHost "  Ruta de backup" $defaultBackup
$proyecto = & $readHost "  Nombre del proyecto activo" "MiProyecto"

# --- Paso 3: Inicializar vault ---
Write-Host "`n─── Paso 3: Inicializando vault ───" -ForegroundColor Yellow

if (-not (Test-Path $vaultPath)) { New-Item -ItemType Directory -Path $vaultPath -Force | Out-Null }

# Copiar templates del vault
$vaultSrc = Join-Path $repoRoot "src\vault"
Get-ChildItem $vaultSrc -File | ForEach-Object {
    Copy-Item $_.FullName $vaultPath -Force
}
# Copiar arquitectura
$arqSrc = Join-Path $vaultSrc "_arquitectura"
if (Test-Path $arqSrc) {
    $arqDest = Join-Path $vaultPath "_arquitectura"
    if (-not (Test-Path $arqDest)) { New-Item -ItemType Directory -Path $arqDest -Force | Out-Null }
    Copy-Item "$arqSrc\*" $arqDest -Recurse -Force
}
Write-Host "  [✓] Vault creado en $vaultPath" -ForegroundColor Green

# --- Paso 4: Inicializar BD ---
Write-Host "─── Paso 4: Inicializando base de datos ───" -ForegroundColor Yellow

$dbPath = Join-Path $vaultPath "memoria_sadit.db"
$schemaPath = Join-Path $repoRoot "src\bd\schema.sql"

if (Test-Path $dbPath) { Remove-Item $dbPath -Force }
& $sqlite.Source $dbPath ".read '$schemaPath'"

# Seed de contexto
& $sqlite.Source $dbPath @"
INSERT INTO contexto_activo (proyecto, clave, valor, prioridad) VALUES
('_global', 'vault_path', '$vaultPath', 10),
('_global', 'db_path', '$dbPath', 10),
('_global', 'backup_path', '$backupPath', 8),
('_global', 'idioma', 'es-ES', 5),
('_global', 'proyecto_activo', '$proyecto', 10),
('_global', 'herramienta_sqlite', '$($sqlite.Source)', 8);
"@
Write-Host "  [✓] BD creada en $dbPath" -ForegroundColor Green

# --- Paso 5: Configuración local ---
Write-Host "─── Paso 5: Guardando configuración ───" -ForegroundColor Yellow

$configContent = @"
# Configuración local de SaDiT (generado por setup.ps1)
`$global:SaDiT_VaultPath = '$vaultPath'
`$global:SaDiT_BackupPath = '$backupPath'
`$global:SaDiT_ProyectoActivo = '$proyecto'
`$global:SaDiT_Version = '1.1.0'
"@
$configDest = Join-Path $repoRoot "config\config.local.ps1"
$configContent | Out-File $configDest -Encoding utf8
Write-Host "  [✓] Configuración guardada" -ForegroundColor Green

# --- Paso 6: Resumen ---
Write-Host "`n╔════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   ✅ SaDiT INSTALADO                   ║" -ForegroundColor Green
Write-Host "╠════════════════════════════════════════╣" -ForegroundColor Cyan
Write-Host "║  Vault: $vaultPath" -ForegroundColor Cyan
Write-Host "║  BD:    $dbPath" -ForegroundColor Cyan  
Write-Host "║  Backup:$backupPath" -ForegroundColor Cyan
Write-Host "╠════════════════════════════════════════╣" -ForegroundColor Cyan
Write-Host "║  Próximos pasos:                      ║" -ForegroundColor Cyan
Write-Host "║  1. Configurar backup automático:     ║" -ForegroundColor Cyan
Write-Host "║     .\src\scripts\programar-backup.ps1 ║" -ForegroundColor Cyan
Write-Host "║  2. Iniciar sesión:                   ║" -ForegroundColor Cyan
Write-Host "║     .\src\scripts\iniciar-sesion.ps1   ║" -ForegroundColor Cyan
Write-Host "║  3. Abrir Obsidian → Abrir vault      ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
