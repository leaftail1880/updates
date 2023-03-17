Write-Host "INSTALLER VERSION 0.0.20"

Add-Type -AssemblyName PresentationFramework

$ROOT = "$([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop))\Minecraft Bedrock Install"

function DownloadArchieve($Uri, $FileName, $Folder = $ROOT) {
  $file = "$Folder\$FileName"

  Invoke-WebRequest -Uri $Uri -OutFile $file
  Expand-Archive -Path $file -DestinationPath $Folder -Force
  Remove-Item -Path $file -Force
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
Provide this file to https://github.com/leaftail1880/updates/issues with tag "MCDownload"

System: $systemType

Error:
$Err
"@

  # Write file
  Set-Content -Path "$ROOT\Error.txt" -Value $logContent
  Write-Error "$Info. Check error boxes under another windows."
  # Show error box
  [System.Windows.MessageBox]::Show("$Info. Check Desktop\Minecraft Bedrock Install\Error.txt for detail.")
  Exit 1
}

function CreateFolder($Path) {
  if (Test-Path -Path $Path -PathType Container -ErrorAction SilentlyContinue) {
    Remove-Item $Path -ErrorAction Stop -Force -Recurse
  }
  Start-Sleep 1
  Write-Host " "
  Write-Host "Создаю папку в ""$Path""..."
  $null = New-item $Path -ItemType Directory -Force -ErrorAction SilentlyContinue -InformationAction SilentlyContinue
  Write-Host " "
}

# Folder
try {
  CreateFolder $ROOT
}
catch {
  Notify "Error while creating folder on desktop" $_
}

# DLL
try {
  Write-Host "Скачиваю дату..."
  DownloadArchieve "https://raw.githubusercontent.com/leaftail1880/updates/main/MC/Data.zip" "Data.zip"
}
catch {
  Notify "Error while downloading DLL's." $_
}

# Launcher
try {
  Write-Host "Скачиваю лаунчер..."
  CreateFolder "$ROOT\MCLauncher"
  DownloadArchieve "https://github.com/MCMrARM/mc-w10-version-launcher/releases/download/0.4.0/MCLauncher.zip" "MCLauncher.zip" "$ROOT\MCLauncher"
}
catch {
  Notify "Error while downloading MCLauncher" $_
}

# Script.ps1
try {
  Write-Host "Скачиваю скрипт для следующего шага..."
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/leaftail1880/updates/main/MC/Script.ps1" -OutFile "$ROOT\Script.ps1"
}
catch {
  Notify "Error while downloading Setup.ps1" $_
}

# Следующий шаг.txt
try {
  Write-Host "Пишу текст справки..."

  $content = @"
Нажмите по файлу SETUP.bat лкм и выберите "Запуск от имени администратора"
"@
  Set-Content -Path "$ROOT\Следующий шаг.txt" -Value $content



  $content2 = @"
powershell.exe -ExecutionPolicy Bypass -File "$ROOT\Script.ps1" -Encoding utf8bom
"@
  Set-Content -Path "$ROOT\SETUP.bat" -Value $content2
}
catch {
  Notify "Error while writing Next.txt" $_
}

Write-Host "Готово. Проверьте окна с сообщениями под другими программами."
$message = @"
Готово! Теперь нажмите пкм по файлу "Рабочий стол/Minecraft Bedrock Install/SETUP.bat" и выберите "Запуск от имени администратора"
"@
[System.Windows.MessageBox]::Show($message)
Exit 0