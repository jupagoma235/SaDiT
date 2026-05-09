# ============================================================
# REGISTRAR ERROR — SaDiT
# Copyright (c) 2026 jupagoma235 — MIT License
# ============================================================
# Registra un error en la BD y, si es crítico o recurrente,
# genera automáticamente un aprendizaje para evitar que se repita.
# ============================================================

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('logica','recursos','referencias','conexiones','general')]
    [string]$Categoria,

    [Parameter(Mandatory=$true)]
    [ValidateRange(1,5)]
    [int]$Severidad,

    [Parameter(Mandatory=$true)]
    [string]$Mensaje,

    [string]$Modulo = "",
    [string]$Detalle = "",
    [string]$Proyecto = "",
    [string]$SesionUUID = ""
)

# --- Configuración ---
$vaultPath = "$env:USERPROFILE\SaDiTVault"
$configFile = Join-Path $PSScriptRoot "..\..\config\config.local.ps1"
if (Test-Path $configFile) { . $configFile }

$dbPath = Join-Path $vaultPath "memoria_sadit.db"

# Detectar sqlite3
$sqlite = Get-Command sqlite3 -ErrorAction SilentlyContinue
if (-not $sqlite) { Write-Error "SQLite no encontrado"; exit 1 }

# --- Obtener sesión activa o crear una temporal ---
if (-not $SesionUUID) {
    $ultima = & $sqlite.Source $dbPath "SELECT uuid FROM sesiones WHERE fin IS NULL ORDER BY inicio DESC LIMIT 1;"
    if ($ultima) { $SesionUUID = $ultima } else { $SesionUUID = [guid]::NewGuid().ToString() }
}

$sesionId = & $sqlite.Source $dbPath "SELECT id FROM sesiones WHERE uuid = '$SesionUUID';"
if (-not $sesionId) {
    & $sqlite.Source $dbPath "INSERT INTO sesiones (uuid, modelo, proyecto, inicio) VALUES ('$SesionUUID', 'sistema', 'Sistema', CURRENT_TIMESTAMP);"
    $sesionId = & $sqlite.Source $dbPath "SELECT last_insert_rowid();"
}

# --- Registrar el error ---
$escapedMensaje = $Mensaje -replace "'", "''"
$escapedDetalle = $Detalle -replace "'", "''"
$escapedModulo = $Modulo -replace "'", "''"
$escapedProyecto = $Proyecto -replace "'", "''"

& $sqlite.Source $dbPath @"
INSERT INTO errores (sesion_id, proyecto, categoria, severidad, modulo, mensaje, detalle)
VALUES ($sesionId, '$escapedProyecto', '$Categoria', $Severidad, '$escapedModulo', '$escapedMensaje', '$escapedDetalle');
"@

$errorId = & $sqlite.Source $dbPath "SELECT last_insert_rowid();"

# --- Auto-aprendizaje: si severidad >= 4, generar aprendizaje ---
if ($Severidad -ge 4) {
    $claveAprendizaje = "error_$Categoria" + "_$([System.IO.Path]::GetInvalidFileNameChars() -join '' | ForEach-Object { $Mensaje -replace $_, '' })"
    $claveAprendizaje = $claveAprendizaje.Substring(0, [Math]::Min($claveAprendizaje.Length, 60))

    & $sqlite.Source $dbPath @"
INSERT INTO aprendizajes (sesion_id, categoria, clave, valor, contexto, peso)
VALUES ($sesionId, 'error_$Categoria', '$claveAprendizaje', '$escapedMensaje', 'Generado automaticamente desde error #$errorId (severidad $Severidad)', 1)
ON CONFLICT(categoria, clave) DO UPDATE SET peso = peso + 1, actualizado = CURRENT_TIMESTAMP;
"@

    $aprendizajeId = & $sqlite.Source $dbPath "SELECT last_insert_rowid();"
    & $sqlite.Source $dbPath "UPDATE errores SET aprendizaje_id = $aprendizajeId WHERE id = $errorId;"
}

# --- Mostrar resultado ---
$severidadLabel = @{1="BAJA";2="MEDIA";3="ALTA";4="CRÍTICA";5="GRAVE"}
$icono = if ($Severidad -ge 4) { "⚠️" } elseif ($Severidad -ge 3) { "⚡" } else { "ℹ️" }

Write-Host "$icono [$($severidadLabel[$Severidad])] $Categoria :: $Mensaje" -ForegroundColor @{1="Gray";2="Yellow";3="DarkYellow";4="Red";5="DarkRed"}[$Severidad]
Write-Host "   ID: $errorId | Módulo: $Modulo | Proyecto: $Proyecto"
if ($Severidad -ge 4) { Write-Host "   🧠 Aprendizaje generado automáticamente" -ForegroundColor Cyan }

return $errorId
