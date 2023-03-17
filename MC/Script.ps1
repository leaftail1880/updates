Write-Host "SETUP VERSION 0.0.16"

Add-Type -AssemblyName PresentationFramework

$DESKTOP = "$([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop))"
$ROOT = "$DESKTOP\Minecraft Bedrock Install"

if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Write-Error "Run PowerShell as administrator!"
  [System.Windows.MessageBox]::Show("Run PowerShell as administrator!")
  Exit
}

Remove-Item "$ROOT\Error.txt" -Force -ErrorAction SilentlyContinue
Remove-Item "$ROOT\SetupError.txt" -Force -ErrorAction SilentlyContinue

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
  Set-Content -Path "$ROOT\SetupError.txt" -Value $logContent
  Write-Error "$Info. Check error boxes under another windows."
  # Show error box
  [System.Windows.MessageBox]::Show("$Info. Check Desktop\Minecraft Bedrock Install\SetupError.txt for detail.")
  Exit 1
}


function PatchDLL($DLLtoPatchFolder, $DLLtoPatchName, $newDLL) {
  $DLLtoPatch = "$DLLtoPatchFolder\$DLLtoPatchName"

  try {
    Write-Host "Patching DLL at $DLLtoPatch"
    takeown /f "$DLLtoPatch"
    icacls "$DLLtoPatch" /grant *S-1-3-4:F /c

    Copy-Item -Path $newDLL -Destination $DLLtoPatchFolder -Force -ErrorAction Stop
  }
  catch {
    Notify "DLL copy failed" $_
  }
}


try {
  Write-Host "Patching DLL's..."

  $DLL = "Windows.ApplicationModel.Store.dll"

  if (Get-Process -Name WinStore.App -ErrorAction SilentlyContinue) {
    try {
      Write-Host "Stopping WinStore.App process..."
      Stop-Process -Name WinStore.App
      Start-Sleep 2
    } 
    catch {
      Notify "Unable to stop process WinStore.App" $_
    }
  }

  PatchDLL "$env:SystemRoot\System32" $DLL "$ROOT\Data\System32\$DLL"
  PatchDLL "$env:SystemRoot\SysWOW64" $DLL "$ROOT\Data\SysWOW64\$DLL"
}
catch {
  Notify "DLL patch failed" $_
}

try {
  Write-Host "Installing Launcher..."
  $LauncherFolder = "$env:ProgramFiles\MCLauncher"

  if (Test-Path -Path $LauncherFolder -PathType Container -ErrorAction SilentlyContinue) {
    Remove-Item $LauncherFolder -ErrorAction Stop -Force -Recurse
  }
  
  Write-Host "Moving files to $env:ProgramFiles\MCLauncher..."
  Move-Item "$ROOT\MCLauncher" $LauncherFolder -Force
  Move-Item "$ROOT\Data\icon.ico" $LauncherFolder -Force

  $ShortcutPath = "$LauncherFolder\Minecraft Bedrock Launcher.lnk"
  
  # Создать объект ярлыка
  Write-Host "Creating Shortcut..."
  $WshShell = New-Object -ComObject WScript.Shell
  $Shortcut = $WshShell.CreateShortcut($ShortcutPath)
  
  $target = "$LauncherFolder\MCLauncher.exe"
  
  # Установить свойства ярлыка
  $Shortcut.TargetPath = $target
  $Shortcut.WorkingDirectory = (Split-Path $target)
  $Shortcut.IconLocation = "$LauncherFolder\icon.ico,0"

  # Сохранить ярлык
  $Shortcut.Save()

  Write-Host "Copying shortcuts..."
  Copy-Item -Path $ShortcutPath -Destination "$DESKTOP" -Force -ErrorAction SilentlyContinue
  Copy-Item -Path $ShortcutPath -Destination "$env:ProgramData\Microsoft\Windows\Start Menu\Programs" -Force -ErrorAction SilentlyContinue
}
catch {
  Notify "Launcher installing failed!" $_
}

try {
  Write-Host "Closing processes associated ROOT folder..."
  Get-Process | Where-Object { $_.ProcessName -eq "notepad" -and $_.Modules.FileName -match $ROOT } | Stop-Process -Force
  Start-Sleep 3
  Write-Host "Removing folder..."
  Remove-Item $ROOT -Recurse -Force
}
catch {
  Notify "Removing setup folder failed!" $_
}

Write-Host "Minecraft Bedrock Installed Successfully! Now open MCLauncher located on Desktop and install any version!"
[System.Windows.MessageBox]::Show("Minecraft Bedrock установлен! Теперь установите сам Minecraft используя ярлык лаунчера на рабочем столе или в стартовом меню.")
Exit