# ============================================================
# RESPALDAR — SaDiT
# ============================================================
# Exporta la BD, sincroniza el vault y guarda metadatos.
# Auto-elevación UAC si no es administrador.
# ============================================================

param(
    [string]$VaultPath = "$env:USERPROFILE\SaDiTVault",
    [string]$BackupPath = "D:\SaDiT_Backup"
)

# Auto-elevación
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

# Cargar configuración local
$configFile = Join-Path $PSScriptRoot "..\..\config\config.local.ps1"
if (Test-Path $configFile) { . $configFile }

# Detectar sqlite3
$sqlite = Get-Command sqlite3 -ErrorAction SilentlyContinue
if (-not $sqlite) { Write-Host "[✗] SQLite no encontrado" -ForegroundColor Red; exit 1 }

$dbPath = Join-Path $VaultPath "memoria_sadit.db"
$fecha = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   SaDiT — RESPALDO                     ║" -ForegroundColor Cyan
Write-Host "║   $fecha              ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan

# Verificar rutas
if (-not (Test-Path $dbPath)) { Write-Host "[✗] BD no encontrada" -ForegroundColor Red; exit 1 }
if (-not (Test-Path $BackupPath)) { New-Item -ItemType Directory -Path $BackupPath -Force | Out-Null }

# Exportar BD
Write-Host "[...] Exportando BD..." -ForegroundColor Yellow
& $sqlite.Source $dbPath ".output '$BackupPath\db_dump.sql'" ".dump" ".output stdout"
Copy-Item $dbPath "$BackupPath\db_dump.db" -Force
Write-Host "[✓] BD exportada" -ForegroundColor Green

# Sincronizar vault
Write-Host "[...] Sincronizando vault..." -ForegroundColor Yellow
if (-not (Test-Path "$BackupPath\vault")) { New-Item -ItemType Directory -Path "$BackupPath\vault" -Force | Out-Null }
Get-ChildItem $VaultPath -File | ForEach-Object { Copy-Item $_.FullName "$BackupPath\vault\$_" -Force }
if (Test-Path (Join-Path $VaultPath "_arquitectura")) {
    Copy-Item (Join-Path $VaultPath "_arquitectura") "$BackupPath\vault\_arquitectura" -Recurse -Force
}
Write-Host "[✓] Vault sincronizado" -ForegroundColor Green

# Metadatos
$info = "FECHA: $fecha`r`nORIGEN: $VaultPath`r`nSQLITE: $(& $sqlite.Source --version)`r`nRESTAURAR: .\src\scripts\restaurar.ps1"
$info | Out-File "$BackupPath\info_entorno.txt" -Encoding utf8

Write-Host "[✓] Respaldo completado en $BackupPath" -ForegroundColor Green
