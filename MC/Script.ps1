Write-Host "SETUP VERSION 0.0.21"

Add-Type -AssemblyName PresentationFramework

$IS_ADMIN = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-NOT $IS_ADMIN) {
  Write-Error "Запусти файл SETUP.bat от имени Администратора!"
  [System.Windows.MessageBox]::Show("Запусти файл SETUP.bat от имени Администратора!")
  Exit
}

$DESKTOP = "$([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop))"
$ROOT = "$DESKTOP\Minecraft Bedrock Install"

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
  # Show error
  Write-Error "$Info. Check error boxes under another windows."
  [System.Windows.MessageBox]::Show("$Info. Check Desktop\Minecraft Bedrock Install\SetupError.txt for detail.")
  Exit 1
}


function PatchDLL($DLLtoPatchFolder, $DLLtoPatchName, $newDLL) {
  $DLLtoPatch = "$DLLtoPatchFolder\$DLLtoPatchName"

  try {
    Write-Host " "
    Write-Host "DLL: $DLLtoPatch"
    Write-Host " "
    takeown /f "$DLLtoPatch"
    icacls "$DLLtoPatch" /grant *S-1-3-4:F /c
    Write-Host " "

    Copy-Item -Path $newDLL -Destination $DLLtoPatchFolder -Force -ErrorAction Stop
  }
  catch {
    Notify "DLL copy failed" $_
  }
}

try {
  Write-Host " "
  Write-Host "Заменяю DLL's..."
  Write-Host " "

  $DLL = "Windows.ApplicationModel.Store.dll"

  $PROCESS = Get-Process -Name WinStore.App -ErrorAction SilentlyContinue
  if ($PROCESS) {
    try {
      Write-Host "Останавливаю WinStore.App..."
      Write-Host " "
      $PROCESS.Kill()
      Start-Sleep 4
    } 
    catch {
      Notify "Unable to stop process WinStore.App" $_
    }
  }

  PatchDLL "$env:SystemRoot\System32" $DLL "$ROOT\Data\System32\$DLL"
  PatchDLL "$env:SystemRoot\SysWOW64" $DLL "$ROOT\Data\SysWOW64\$DLL"
  Write-Host " "

}
catch {
  Notify "DLL patch failed" $_
}

try {
  Write-Host " "
  Write-Host "Устанавливаю лаунчер..."
  Write-Host " "

  $LauncherFolder = "$env:ProgramFiles\MCLauncher"

  if (Test-Path -Path $LauncherFolder -PathType Container -ErrorAction SilentlyContinue) {
    Remove-Item $LauncherFolder -ErrorAction Stop -Force -Recurse
  }
  
  Write-Host "Перемещаю файлы в $env:ProgramFiles\MCLauncher..."
  Write-Host " "
  Move-Item "$ROOT\MCLauncher" $LauncherFolder -Force
  Move-Item "$ROOT\Data\icon.ico" $LauncherFolder -Force

  $ShortcutPath = "$LauncherFolder\Minecraft Bedrock Launcher.lnk"
  
  # Создать объект ярлыка
  Write-Host "Настраиваю ярлыки..."
  Write-Host " "
  $WshShell = New-Object -ComObject WScript.Shell
  $Shortcut = $WshShell.CreateShortcut($ShortcutPath)
  
  $target = "$LauncherFolder\MCLauncher.exe"
  
  # Установить свойства ярлыка
  $Shortcut.TargetPath = $target
  $Shortcut.WorkingDirectory = (Split-Path $target)
  $Shortcut.IconLocation = "$LauncherFolder\icon.ico,0"

  # Сохранить ярлык
  $Shortcut.Save()

  Write-Host "Копирую ярлыки..."
  Write-Host " "
  Copy-Item -Path $ShortcutPath -Destination "$DESKTOP" -Force -ErrorAction SilentlyContinue
  Copy-Item -Path $ShortcutPath -Destination "$env:ProgramData\Microsoft\Windows\Start Menu\Programs" -Force -ErrorAction SilentlyContinue
}
catch {
  Notify "Launcher installing failed!" $_
}

try {
  Start-Sleep 3
  Write-Host "Убираю установочные файлы..."
  Write-Host " "
  try {
    Remove-Item $ROOT -Recurse -Force
  }
  catch {
    $Info = "Не удалось удалить установочную папку. Зайкройте блокнот с гайдом оттуда если он открыт и удалите ее вручную. (Это не влияет на установку Minecraft)"
    Write-Host $Info
    [System.Windows.MessageBox]::Show($Info)
  }
}
catch {
  Notify "Removing setup folder failed!" $_
}

$message = "Готово! Теперь установите сам Minecraft используя ярлык лаунчера на рабочем столе или в стартовом меню."

Write-Host $message
[System.Windows.MessageBox]::Show($message)
Exit 0