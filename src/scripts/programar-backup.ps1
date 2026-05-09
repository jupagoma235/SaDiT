# ============================================================
# PROGRAMAR BACKUP — SaDiT
# Copyright (c) 2026 jupagoma235 — MIT License
# ============================================================
# Crea una tarea programada semanal para ejecutar el backup.
# Auto-elevación UAC si no es administrador.
# ============================================================

param(
    [string]$BackupScriptPath = "$PSScriptRoot\respaldar.ps1"
)

# Auto-elevación
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

$tarea = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Description>SaDiT — Respaldo semanal del vault y base de datos</Description>
  </RegistrationInfo>
  <Triggers>
    <CalendarTrigger>
      <StartBoundary>2026-05-17T10:00:00</StartBoundary>
      <Enabled>true</Enabled>
      <ScheduleByWeek>
        <DaysOfWeek><Sunday /></DaysOfWeek>
        <WeeksInterval>1</WeeksInterval>
      </ScheduleByWeek>
    </CalendarTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <Enabled>true</Enabled>
    <StartWhenAvailable>true</StartWhenAvailable>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>powershell.exe</Command>
      <Arguments>-File "$BackupScriptPath"</Arguments>
    </Exec>
  </Actions>
</Task>
"@

$xmlFile = "$env:TEMP\SaDiT_Backup.xml"
$tarea | Out-File $xmlFile -Encoding utf8
schtasks /CREATE /TN "SaDiT_Backup" /XML $xmlFile /F

if ($?) {
    Write-Host "[✓] Tarea programada creada: SaDiT_Backup (domingos 10:00)" -ForegroundColor Green
} else {
    Write-Host "[✗] Error al crear la tarea. ¿Ejecutaste como administrador?" -ForegroundColor Red
}
Remove-Item $xmlFile -Force -ErrorAction SilentlyContinue
