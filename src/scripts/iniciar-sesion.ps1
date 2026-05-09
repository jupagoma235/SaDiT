# ============================================================
# INICIAR SESIÓN — SaDiT
# Copyright (c) 2026 jupagoma235 — MIT License
# ============================================================
# Prepara el entorno, crea una sesión en la BD y genera
# el prompt de contexto para el agente IA.
# ============================================================

param(
    [string]$VaultPath = "$env:USERPROFILE\SaDiTVault",
    [string]$Proyecto = "default"
)

# --- Cargar configuración local si existe ---
$configFile = Join-Path $PSScriptRoot "..\..\config\config.local.ps1"
if (Test-Path $configFile) { . $configFile }

Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   SaDiT — INICIAR SESIÓN              ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# --- 1. Detectar sqlite3 ---
$sqlite = Get-Command sqlite3 -ErrorAction SilentlyContinue
if (-not $sqlite) {
    Write-Host "[!] SQLite no encontrado. Instalando..." -ForegroundColor Yellow
    winget install -e --id SQLite.SQLite --accept-source-agreements --accept-package-agreements
    $sqlite = Get-Command sqlite3 -ErrorAction SilentlyContinue
    if (-not $sqlite) {
        Write-Host "[✗] No se pudo instalar SQLite. Instálalo manualmente." -ForegroundColor Red
        exit 1
    }
}
$sqlitePath = $sqlite.Source
Write-Host "[✓] SQLite: $(& $sqlitePath --version)" -ForegroundColor Green

# --- 2. Verificar / crear BD ---
$dbPath = Join-Path $VaultPath "memoria_sadit.db"
$schemaPath = Join-Path $PSScriptRoot "..\bd\schema.sql"
if (-not (Test-Path $dbPath)) {
    Write-Host "[...] Creando base de datos..." -ForegroundColor Yellow
    if (-not (Test-Path $VaultPath)) { New-Item -ItemType Directory -Path $VaultPath -Force | Out-Null }
    & $sqlitePath $dbPath ".read '$schemaPath'"
    # Seed de contexto inicial
    & $sqlitePath $dbPath "INSERT INTO contexto_activo (proyecto, clave, valor, prioridad) VALUES ('_global', 'vault_path', '$VaultPath', 10), ('_global', 'db_path', '$dbPath', 10);"
    Write-Host "[✓] Base de datos creada en $dbPath" -ForegroundColor Green
} else {
    Write-Host "[✓] Base de datos encontrada" -ForegroundColor Green
}

# --- 3. Crear sesión ---
$uuid = [guid]::NewGuid().ToString()
& $sqlitePath $dbPath "INSERT INTO sesiones (uuid, modelo, proyecto, inicio) VALUES ('$uuid', 'opencode', '$Proyecto', CURRENT_TIMESTAMP);"
Write-Host "[✓] Sesión iniciada: $uuid" -ForegroundColor Green

# --- 4. Generar prompt con contexto ---
$promptBase = Get-Content (Join-Path $PSScriptRoot "..\vault\_prompt-inicial.md") -Raw -ErrorAction SilentlyContinue
if (-not $promptBase) {
    $promptBase = "# Prompt de contexto para SaDiT`n`nEl agente debe leer el vault y consultar la BD."
}

$contexto = & $sqlitePath $dbPath "SELECT clave, valor, prioridad FROM contexto_activo WHERE prioridad >= 5 ORDER BY prioridad DESC;"
$aprendizajes = & $sqlitePath $dbPath "SELECT categoria, clave, valor FROM aprendizajes WHERE peso >= 2 ORDER BY peso DESC LIMIT 10;"

$promptFinal = @"
$promptBase

## CONTEXTO ACTIVO
$contexto

## APRENDIZAJES RELEVANTES
$aprendizajes

## SESIÓN ACTUAL
- UUID: $uuid
- Proyecto: $Proyecto
- Fecha: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
- Vault: $VaultPath
- BD: $dbPath
"@

$promptFile = Join-Path $VaultPath "_ultimo-prompt.txt"
$promptFinal | Out-File -FilePath $promptFile -Encoding utf8

Write-Host ""
Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   PROMPT LISTO                        ║" -ForegroundColor Cyan
Write-Host "║   Pégalo como primer mensaje al       ║" -ForegroundColor Cyan
Write-Host "║   agente IA para iniciar la sesión    ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "Prompt: $promptFile" -ForegroundColor Yellow
Write-Host "UUID:   $uuid" -ForegroundColor Yellow
