Write-Host "INSTALLER VERSION 0.0.26"

$ROOT = ".\Packet\MCLauncher"

function DownloadArchive($Uri, $FileName, $Folder = $ROOT) {
  $file = "$Folder\$FileName"

  Invoke-WebRequest -Uri $Uri -OutFile $file
  Expand-Archive -Path $file -DestinationPath $Folder -Force
  Remove-Item -Path $file -Force
}

Remove-Item $ROOT -Force -Recurse -ErrorAction Ignore
New-item $ROOT -ItemType Directory -Force -ErrorAction Stop
Write-Host " "
Write-Host "Downloading launcher..."
Write-Host " "
DownloadArchive "https://github.com/MCMrARM/mc-w10-version-launcher/releases/download/0.4.0/MCLauncher.zip" "MCLauncher.zip" $ROOT
