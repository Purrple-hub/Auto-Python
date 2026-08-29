# Auto-Python

Lazy Python installer. One script per OS, installs the latest Python and fixes PATH.

## Usage

**Windows** (run as Admin):
```powershell
PowerShell -ExecutionPolicy Bypass -File Scripts/windows.ps1
```

**Linux**:
```bash
sudo bash Scripts/linux.sh
```

**Mac**:
```bash
sudo bash Scripts/macos.sh
```

That's it. Restart your terminal and run `python --version`.
