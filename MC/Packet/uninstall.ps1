chcp 437

echo "Running at $PSScriptRoot"

if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host("Not running as administrator! Please run PowerShell as admin.") -ForegroundColor Red;
    Write-Host("You can do so by running cmd or powershell as admin and then running") -ForegroundColor Yellow
    Write-Host("powershell '$PSCommandPath'") -ForegroundColor Yellow
    pause;
    exit;
}

function info() { 
  echo "System: $($(Get-ChildItem C:\Windows\System32\Windows.ApplicationModel.Store.dll).Length / 1024) Must be: $($(Get-ChildItem '$PSScriptRoot\temp\System32\Windows.ApplicationModel.Store.dll').Length / 1024)"
}

info

taskkill /f /im WinStore.App.exe
taskkill /f /im Minecraft.Windows.exe
timeout 1

takeown /f "C:\Windows\System32\Windows.ApplicationModel.Store.dll"
icacls "C:\Windows\System32\Windows.ApplicationModel.Store.dll" /grant *S-1-3-4:F /c
timeout 1

Copy-Item -Verbose -Force "$PSScriptRoot\original\System32\Windows.ApplicationModel.Store.dll" "C:\Windows\System32\"

takeown /f "C:\Windows\SysWOW64\Windows.ApplicationModel.Store.dll"
icacls "C:\Windows\SysWOW64\Windows.ApplicationModel.Store.dll" /grant *S-1-3-4:F /c
timeout 1

Copy-Item "C:\Windows\SysWOW64\Windows.ApplicationModel.Store.dll" "$PSScriptRoot\original\SysWOW64\"
Copy-Item -Verbose -Force "$PSScriptRoot\original\SysWOW64\Windows.ApplicationModel.Store.dll" "C:\Windows\SysWOW64\"

info

pause