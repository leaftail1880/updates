Write-Host "SETUP VERSION 0.0.4"

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
  try {
    Copy-Item -Path $newDLL -Destination $DLLtoPatchFolder -Force -ErrorAction Stop

  }
  catch {
    Notify "DLL copy failed" $_
  }
}

function CreateFolder($Path) {
  if (Test-Path -Path $Path -PathType Leaf -ErrorAction SilentlyContinue) {
    Remove-Item $Path -ErrorAction Stop -Force -Recurse
  }
  Start-Sleep 1
  New-item $Path -ItemType Directory -Force -ErrorAction SilentlyContinue
}




try {

  $DLL = "Windows.ApplicationModel.Store.dll"

  # Determine system architecture
  if ([Environment]::Is64BitOperatingSystem) {
    PatchDLL "$env:SystemRoot\System32" $DLL "$ROOT/Data/System32/$DLL"
  }
  elseif ([Environment]::Is32BitOperatingSystem) {
    PatchDLL "$env:SystemRoot\SysWOW64" $DLL "$ROOT/Data/SysWOW64/$DLL"
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

try {
  $LauncherFolder = "$env:ProgramFiles/MCLauncher"

  
  CreateFolder $LauncherFolder
  
  Move-Item "$ROOT/Data/icon.png" -Destination $LauncherFolder
  $ShortcutPath = "$LauncherFolder/Minecraft Bedrock Launcher.lnk"
  
  # Создать объект ярлыка
  $WshShell = New-Object -ComObject WScript.Shell
  $Shortcut = $WshShell.CreateShortcut($ShortcutPath)
  
  $target = "$LauncherFolder/MCLauncher.exe"
  
  # Установить свойства ярлыка
  $Shortcut.TargetPath = $target
  $Shortcut.WorkingDirectory = (Split-Path $target)
  $Shortcut.IconLocation = "$LauncherFolder/icon.png,0"

  # Сохранить ярлык
  $Shortcut.Save()

  Copy-Item -Path $ShortcutPath -Destination "$DESKTOP" -Force -ErrorAction SilentlyContinue
  Copy-Item -Path $ShortcutPath -Destination "$env:ProgramData/Microsoft/Windows/Start Menu/Programs/" -Force -ErrorAction SilentlyContinue
}
catch {
  Notify "Launcher installing failed!" $_
}

try {
  Remove-Item $ROOT -Recurse -Force
}
catch {
  Notify "Removing setup folder failed!" $_
}

Write-Host "Minecraft Bedrock Installed Successfully! Now open MCLauncher located on Desktop and install any version!"
[System.Windows.MessageBox]::Show("Minecraft Bedrock Installed Successfully! Now open MCLauncher located on Desktop and install any version!")
Exit