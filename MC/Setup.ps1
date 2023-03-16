Write-Host "SETUP VERSION 0.0.1"

Add-Type -AssemblyName PresentationFramework

$DESKTOP = "$([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop))"
$ROOT = "$DESKTOP/Minecraft Bedrock Install"

if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Write-Error "Run PowerShell as administrator!"
  [System.Windows.MessageBox]::Show("Run PowerShell as administrator!")
  Exit
}


function PatchDLL($DLLtoPatchFolder, $DLLtoPatchName, $newDLL) {
  $DLLtoPatch = "$DLLtoPatchFolder/$DLLtoPatchName"

  Stop-Process -Name WinStore.App -ErrorAction SilentlyContinue

  takeown /f "$DLLtoPatch"
  icacls "$DLLtoPatch" /grant *S-1-3-4:F /c
  Copy-Item -Path $newDLL -Destination $DLLtoPatchFolder -Force
}



$DLL = "Windows.ApplicationModel.Store.dll"

# Determine system architecture
if ([Environment]::Is64BitOperatingSystem) {
  PatchDLL "$env:SystemRoot\System32" $DLL "$ROOT/DLL/System32/$DLL"
}
elseif ([Environment]::Is32BitOperatingSystem) {
  PatchDLL "$env:SystemRoot\SysWOW64" $DLL "$ROOT/DLL/SysWOW64/$DLL"
}
else {
  Write-Error "Setup Error: Unknown architecture"
  [System.Windows.MessageBox]::Show("Setup Error: Unknown architecture")
  Exit
}

# Создать объект ярлыка
$WshShell = New-Object -ComObject WScript.Shell
$shortcut = $WshShell.CreateShortcut("$DESKTOP\MCLauncher.ink")

$target = "$ROOT/MCLauncher/MCLaucher.exe"

# Установить свойства ярлыка
$shortcut.TargetPath = $target
$shortcut.WorkingDirectory = (Split-Path $target)
$shortcut.IconLocation = "$target,0"

# Сохранить ярлык
$shortcut.Save()

Remove-Item "$ROOT/DLL" -Recurse -Force

Write-Host "Minecraft Bedrock Installed Successfully! Now open MCLauncher located on Desktop and install any version!"
[System.Windows.MessageBox]::Show("Minecraft Bedrock Installed Successfully! Now open MCLauncher located on Desktop and install any version!")
Exit