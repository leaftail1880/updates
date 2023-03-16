Write-Host "SETUP VERSION 0.0.1"

Add-Type -AssemblyName PresentationFramework

$DESKTOP = "$([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop))"
$ROOT = "$DESKTOP/Minecraft Bedrock Install"

if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Write-Error "Run PowerShell as administrator!"
  [System.Windows.MessageBox]::Show("Run PowerShell as administrator!")
  Exit
}

function Notify($Info, $Err) {
  # Determine system architecture
  if ([Environment]::Is64BitOperatingSystem) {
    $systemType = "x64"
  }
  elseif ([Environment]::Is32BitOperatingSystem) {
    $systemType = "x86 (32)"
  }
  else {
    $systemType = "Unknown"
  }

  # Define log content
  $logContent = @"
Provide this file to https://github.com/leaftail1880/updates/issues with tag "MCSetup"

System: $systemType

Error:
$Err
"@

  # Write file
  Set-Content -Path "$ROOT\SError.txt" -Value $logContent
  Write-Error "$Info. Check error boxes under another windows."
  # Show error box
  [System.Windows.MessageBox]::Show("$Info. Check Desktop/Minecraft Bedrock Install/SError.txt for detail.")
  Exit 1
}


function PatchDLL($DLLtoPatchFolder, $DLLtoPatchName, $newDLL) {
  $DLLtoPatch = "$DLLtoPatchFolder/$DLLtoPatchName"

  try {
    Stop-Process -Name WinStore.App
  } 
  catch {
    Write-Error $_
  }

  takeown /f "$DLLtoPatch"
  icacls "$DLLtoPatch" /grant *S-1-3-4:F /c
  Copy-Item -Path $newDLL -Destination $DLLtoPatchFolder -Force
}


try {

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
}
catch {
  Notify "DLL patch failed" $_
}

# Создать объект ярлыка
$WshShell = New-Object -ComObject WScript.Shell
$shortcut = $WshShell.CreateShortcut("$DESKTOP\MCLauncher.lnk")

# Установить свойства ярлыка
$shortcut.TargetPath = "$ROOT/MCLauncher/MCLaucher.exe"

# Сохранить ярлык
$shortcut.Save()

try {
  Remove-Item "$ROOT/DLL" -Recurse -Force

}
catch {
  Notify "Removing DLL folder failed" $_
}

Write-Host "Minecraft Bedrock Installed Successfully! Now open MCLauncher located on Desktop and install any version!"
[System.Windows.MessageBox]::Show("Minecraft Bedrock Installed Successfully! Now open MCLauncher located on Desktop and install any version!")
Exit