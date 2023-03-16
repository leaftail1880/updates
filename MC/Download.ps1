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
  Write-Host "Script failed. Check error boxes under another windows."
  # Show error box
  [System.Windows.MessageBox]::Show("$ErrorType Check Desktop/Minecraft Bedrock Install/Error.txt for detail.")
  Exit
}

try {
  DownloadArchieve "https://raw.githubusercontent.com/leaftail1880/updates/main/MC/DLL.zip" "DLL.zip"
}
catch {
  Notify "Error while downloading DLL's." $_
}

try {
  DownloadArchieve "https://github.com/MCMrARM/mc-w10-version-launcher/releases/download/0.4.0/MCLauncher.zip" "MCLauncher.zip"
}
catch {
  Notify "Error while downloading MCLauncher." $_
}