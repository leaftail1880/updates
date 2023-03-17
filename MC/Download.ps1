Write-Host "INSTALLER VERSION 0.0.13"

Add-Type -AssemblyName PresentationFramework

$ROOT = "$([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop))/Minecraft Bedrock Install"

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
  [System.Windows.MessageBox]::Show("$Info. Check Desktop/Minecraft Bedrock Install/Error.txt for detail.")
  Exit 1
}

function CreateFolder($Path) {
  if (Test-Path -Path $Path -PathType Container -ErrorAction SilentlyContinue) {
    Remove-Item $Path -ErrorAction Stop -Force -Recurse
  }
  Start-Sleep 1
  New-item $Path -ItemType Directory -Force -ErrorAction SilentlyContinue
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
  DownloadArchieve "https://raw.githubusercontent.com/leaftail1880/updates/main/MC/Data.zip" "Data.zip"
}
catch {
  Notify "Error while downloading DLL's." $_
}

# Launcher
try {
  CreateFolder "$ROOT\MCLauncher"
  DownloadArchieve "https://github.com/MCMrARM/mc-w10-version-launcher/releases/download/0.4.0/MCLauncher.zip" "MCLauncher.zip" "$ROOT\MCLauncher"
}
catch {
  Notify "Error while downloading MCLauncher" $_
}

# Setup.ps1
try {
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/leaftail1880/updates/main/MC/Setup.ps1" -OutFile "$ROOT\Setup.ps1"
}
catch {
  Notify "Error while downloading Setup.ps1" $_
}

# Next.txt
try {
  $content = @"
Откройте PowerShell от имени Администратора нажав ПКМ по иконке Windows в левом нижнем углу. 

Введите следующую команду и нажмите Enter:

. "$ROOT\Setup.ps1"
"@

  Set-Content -Path "$ROOT\Next.txt" -Value $content
}
catch {
  Notify "Error while writing Next.txt" $_
}

Write-Host "Done. Check message boxes under another windows."
[System.Windows.MessageBox]::Show("Done! Check Desktop/Minecraft Bedrock Install/Next.txt for next steps.")
Exit 0