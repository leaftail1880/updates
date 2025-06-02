chcp 437

echo "Running at $PSScriptRoot"

if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host("Not running as administrator! Please run PowerShell as admin.") -ForegroundColor Red;
    Write-Host("You can do so by running cmd or powershell as admin and then running") -ForegroundColor Yellow
    Write-Host("powershell '$PSCommandPath'") -ForegroundColor Yellow
    pause;
    exit;
}

mkdir -Force "$PSScriptRoot\original" >> $null
mkdir -Force "$PSScriptRoot\original\System32" >> $null
mkdir -Force "$PSScriptRoot\original\SysWOW64" >> $null

taskkill /f /im WinStore.App.exe
taskkill /f /im Minecraft.Windows.exe
timeout 1

echo " "
echo " "
echo " "
echo "Before patch"
echo " "
$mustBe = $(Get-ChildItem "$PSScriptRoot\System32\Windows.ApplicationModel.Store.dll").Length / 1024
echo "Actual: $($(Get-ChildItem C:\Windows\System32\Windows.ApplicationModel.Store.dll).Length / 1024) Must be: $($mustBe)"
echo " "
echo " "
echo " "
echo " "
echo " "

takeown /f "C:\Windows\System32\Windows.ApplicationModel.Store.dll"
icacls "C:\Windows\System32\Windows.ApplicationModel.Store.dll" /grant *S-1-3-4:F /c

Copy-Item "C:\Windows\System32\Windows.ApplicationModel.Store.dll" "$PSScriptRoot\original\System32\"
Copy-Item -Verbose -Force "$PSScriptRoot\temp\System32\Windows.ApplicationModel.Store.dll" "C:\Windows\System32\"

$mustBe = $(Get-ChildItem "$PSScriptRoot\System32\Windows.ApplicationModel.Store.dll").Length / 1024
echo "Actual: $($(Get-ChildItem C:\Windows\System32\Windows.ApplicationModel.Store.dll).Length / 1024) Must be: $($mustBe)"

# takeown /f "C:\Windows\SysWOW64\Windows.ApplicationModel.Store.dll"
# icacls "C:\Windows\SysWOW64\Windows.ApplicationModel.Store.dll" /grant *S-1-3-4:F /c
# timeout 1

# Copy-Item "C:\Windows\SysWOW64\Windows.ApplicationModel.Store.dll" "$PSScriptRoot\original\SysWOW64\"
# Copy-Item -Verbose -Force "$PSScriptRoot\temp\SysWOW64\Windows.ApplicationModel.Store.dll" "C:\Windows\SysWOW64\"

echo " "
echo "Otherwise, use this command"
echo " "
echo "Copy-Item -Verbose -Force ""$PSScriptRoot\temp\System32\Windows.ApplicationModel.Store.dll"" ""C:\Windows\System32\"""
echo " "
echo " "