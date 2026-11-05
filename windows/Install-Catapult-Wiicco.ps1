# Wiicco Catapult client for Windows: installs the official Catapult app from XDT (if missing),
# adds the Wiicco logo, and a scheduled task that puts the logo back after every Catapult update.
# One line (PowerShell):  irm https://raw.githubusercontent.com/robby1312/catapult-client/main/windows/Install-Catapult-Wiicco.ps1 | iex
# Or as file:             powershell -ExecutionPolicy Bypass -File Install-Catapult-Wiicco.ps1
# Remove:                powershell -ExecutionPolicy Bypass -File Install-Catapult-Wiicco.ps1 -Remove
param([switch]$Remove)
$ErrorActionPreference = 'Stop'
$CatapultUrl = 'https://www.catapultsoft.com/Download/GetWindowsClient/'   # official XDT 'Catapult Client Only' installer (.exe)
$LogoUrl     = 'https://raw.githubusercontent.com/robby1312/catapult-client/main/assets/Logo.png'
$AppDir      = 'C:\Program Files\XDT\Catapult'
$WDir        = 'C:\ProgramData\Wiicco\Catapult'
$Task        = 'Wiicco Catapult logo'

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole('Administrators')) {
  $self = $PSCommandPath
  if (-not $self) { $self = Join-Path $env:TEMP 'Install-Catapult-Wiicco.ps1'; Invoke-WebRequest -UseBasicParsing 'https://raw.githubusercontent.com/robby1312/catapult-client/main/windows/Install-Catapult-Wiicco.ps1' -OutFile $self }
  Start-Process powershell "-ExecutionPolicy Bypass -File `"$self`" $(if($Remove){'-Remove'})" -Verb RunAs; return }

if ($Remove) {
  Unregister-ScheduledTask -TaskName $Task -Confirm:$false -ErrorAction SilentlyContinue
  Remove-Item "$AppDir\Logo.png", $WDir -Recurse -Force -ErrorAction SilentlyContinue
  Write-Host 'Wiicco Catapult branding removed.'; return }

New-Item -ItemType Directory -Force -Path $WDir | Out-Null
if (-not (Test-Path "$AppDir") -and $CatapultUrl) {
  $dl = Join-Path $env:TEMP 'catapult-client-setup.exe'
  Write-Host 'Downloading Catapult from XDT...'; Invoke-WebRequest -UseBasicParsing $CatapultUrl -OutFile $dl
  Start-Process $dl -Wait
}
if ($LogoUrl) { Invoke-WebRequest -UseBasicParsing $LogoUrl -OutFile "$WDir\Logo.png" } elseif (Test-Path "$PSScriptRoot\Logo.png") { Copy-Item "$PSScriptRoot\Logo.png" "$WDir\Logo.png" -Force }
@"
`$s='$WDir\Logo.png'; `$d='$AppDir\Logo.png'
if ((Test-Path '$AppDir') -and (Test-Path `$s) -and (-not (Test-Path `$d) -or (Get-FileHash `$s).Hash -ne (Get-FileHash `$d).Hash)) { Copy-Item `$s `$d -Force }
"@ | Set-Content "$WDir\apply-logo.ps1" -Encoding UTF8
$act = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$WDir\apply-logo.ps1`""
$trg = @((New-ScheduledTaskTrigger -AtStartup), (New-ScheduledTaskTrigger -AtLogOn), (New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Hours 1)))
Register-ScheduledTask -TaskName $Task -Action $act -Trigger $trg -User 'SYSTEM' -RunLevel Highest -Force | Out-Null
& powershell -NoProfile -ExecutionPolicy Bypass -File "$WDir\apply-logo.ps1"
Get-Process Catapult -ErrorAction SilentlyContinue | Stop-Process -Force
if (Test-Path "$AppDir\Logo.png") { Write-Host 'Done: Wiicco logo installed. Start Catapult.' } else { Write-Host 'Catapult not found in' $AppDir }
