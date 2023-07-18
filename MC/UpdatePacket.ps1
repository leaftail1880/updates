Write-Host "INSTALLER VERSION 0.0.25"

Add-Type -AssemblyName PresentationFramework

$ROOT = ".\NewPacket"

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
  Write-Host "Creating folder on path ""$Path""..."
  $null = New-item $Path -ItemType Directory -Force -ErrorAction SilentlyContinue -InformationAction SilentlyContinue
  Write-Host " "
}

Remove-Item $ROOT -Force -Recurse -ErrorAction Ignore

# Folder
try {
  CreateFolder $ROOT
}
catch {
  Notify "Error while creating folder" $_
}

try {
  Expand-Archive "./Data.zip" $ROOT
}
catch {
  Notify "Error while downloading data" $_
}

# Launcher
try {
  Write-Host "Downloading launcher..."
  Write-Host " "
  CreateFolder "$ROOT\Data\MCLauncher"
  DownloadArchieve "https://github.com/MCMrARM/mc-w10-version-launcher/releases/download/0.4.0/MCLauncher.zip" "MCLauncher.zip" "$ROOT\Data\MCLauncher"
}
catch {
  Notify "Error while downloading MCLauncher" $_
}

# Script.ps1
try {
  Write-Host "Copying Script.ps1..."
  Write-Host " "
  Copy-Item ".\Script.ps1" -Destination "$ROOT\Data"
}
catch {
  Notify "Error while copying Script.ps1" $_
}

# Следующий шаг.txt
try {
  Write-Host "Writing SETUP.bat..."
  Write-Host " "

  $content2 = @"
powershell.exe -ExecutionPolicy Bypass -File "%USERPROFILE%\Downloads\Packet\Data\Script.ps1" -Encoding utf8bom
PAUSE
"@
  Set-Content -Path "$ROOT\SETUP.bat" -Value $content2
}
catch {
  Notify "Error while writing setup.bat" $_
}

try {
  Compress-Archive -Path "$ROOT\*" -DestinationPath ".\Packet.zip" -Force
  Remove-Item -Path "$ROOT" -Force -Recurse
}
catch {
  Notify "Packing failed" $_
}

Write-Host "Done."
Exit 0