# Catapult for Wiicco

Installs the **Catapult** file transfer app for use with Wiicco servers, with Wiicco branding.

- Downloads the official Catapult client directly from XDT ([catapultsoft.com](https://www.catapultsoft.com/Download)) if it is not installed yet.
- Adds the Wiicco logo to the Catapult window.
- Keeps the logo in place after every Catapult update (small background service).

## Install

### Mac
**Option 1: installer package.** Download `Catapult-for-Wiicco-<version>.pkg` from the [latest release](https://github.com/robby1312/catapult-client/releases/latest) and double-click it.

**Option 2: one line in Terminal.**
```bash
curl -fsSL https://raw.githubusercontent.com/robby1312/catapult-client/main/install-mac.sh | bash
```

### Windows
Open **PowerShell** and run:
```powershell
irm https://raw.githubusercontent.com/robby1312/catapult-client/main/windows/Install-Catapult-Wiicco.ps1 | iex
```
Windows asks for administrator permission once.

## Remove the Wiicco branding
The Catapult app itself stays installed.

- **Mac:** `sudo bash /Library/Wiicco/Catapult/uninstall.sh`
- **Windows (PowerShell):** `& ([scriptblock]::Create((irm https://raw.githubusercontent.com/robby1312/catapult-client/main/windows/Install-Catapult-Wiicco.ps1))) -Remove`

## What gets installed

| | Mac | Windows |
|---|---|---|
| Catapult app | `/Applications/Catapult.app` (from XDT) | `C:\Program Files\XDT\Catapult` (from XDT) |
| Wiicco logo | `/Library/Wiicco/Catapult/Logo.png` | `C:\ProgramData\Wiicco\Catapult\Logo.png` |
| Logo service | LaunchDaemon `com.wiicco.catapult-logo` | Scheduled task "Wiicco Catapult logo" |
| Log | `/var/log/wiicco-catapult-install.log` | |

Catapult is a product of XDT Pty Ltd. This repository only automates the installation and adds Wiicco branding as described in the Catapult manual.

## For Wiicco: building the Mac package
On a Mac: `bash mac/build-pkg.sh` creates `mac/Catapult-for-Wiicco-<version>.pkg`. Optional signing: `SIGN_ID="Developer ID Installer: ..." bash mac/build-pkg.sh`. Upload the pkg to a GitHub release as `Catapult-for-Wiicco.pkg`.
