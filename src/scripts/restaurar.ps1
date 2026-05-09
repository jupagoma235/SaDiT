# ============================================================
# RESTAURAR — SaDiT
# Copyright (c) 2026 jupagoma235 — MIT License
# ============================================================
# Restaura vault y BD desde un backup previo.
# Auto-elevación UAC si no es administrador.
# ============================================================

param(
    [string]$BackupPath = "D:\SaDiT_Backup",
    [string]$VaultDestino = "$env:USERPROFILE\SaDiTVault"
)

# Auto-elevación
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   SaDiT — RESTAURAR                    ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan

# Verificar backup
if (-not (Test-Path $BackupPath)) { Write-Host "[✗] Backup no encontrado en $BackupPath" -ForegroundColor Red; exit 1 }

# Instalar SQLite si no existe
$sqlite = Get-Command sqlite3 -ErrorAction SilentlyContinue
if (-not $sqlite) {
    Write-Host "[!] Instalando SQLite..." -ForegroundColor Yellow
    winget install -e --id SQLite.SQLite --accept-source-agreements --accept-package-agreements
    $sqlite = Get-Command sqlite3 -ErrorAction SilentlyContinue
    if (-not $sqlite) { Write-Host "[✗] Error instalando SQLite" -ForegroundColor Red; exit 1 }
}

# Restaurar vault
if (Test-Path "$BackupPath\vault") {
    Write-Host "[...] Restaurando vault..." -ForegroundColor Yellow
    if (-not (Test-Path $VaultDestino)) { New-Item -ItemType Directory -Path $VaultDestino -Force | Out-Null }
    Get-ChildItem "$BackupPath\vault" -Recurse -File | ForEach-Object {
        $rel = $_.FullName.Substring(("$BackupPath\vault").Length + 1)
        $dest = Join-Path $VaultDestino $rel
        $dir = Split-Path $dest -Parent
        if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
        Copy-Item $_.FullName $dest -Force
    }
    Write-Host "[✓] Vault restaurado" -ForegroundColor Green
}

# Restaurar BD
$dbDest = Join-Path $VaultDestino "memoria_sadit.db"
if (Test-Path "$BackupPath\db_dump.sql") {
    Write-Host "[...] Restaurando BD..." -ForegroundColor Yellow
    & $sqlite.Source $dbDest ".read '$BackupPath\db_dump.sql'"
    Write-Host "[✓] BD restaurada" -ForegroundColor Green
} elseif (Test-Path "$BackupPath\db_dump.db") {
    Copy-Item "$BackupPath\db_dump.db" $dbDest -Force
    Write-Host "[✓] BD restaurada (binario)" -ForegroundColor Green
}

Write-Host "[✓] Restauración completada" -ForegroundColor Green
Write-Host "Vault: $VaultDestino"
Write-Host "Para iniciar sesión: .\src\scripts\iniciar-sesion.ps1"
