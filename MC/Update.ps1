$tempFolder = New-Item -ItemType Directory -Path $env:TEMP\MyTempFolder
$tempPath = $tempFolder.FullName

# Use the temp folder
Write-Output "Using temp folder $($tempPath)"

$file = "$tempPath\DLL.zip"

Invoke-WebRequest -Uri "https://raw.githubusercontent.com/leaftail1880/updates/main/MC/DLL.zip" -OutFile $file
Expand-Archive -Path $file -DestinationPath $tempPath
# Rename-Item "$globalRP/temp" -NewName $packName
Remove-Item -Path $file -Force


# Delete the temp folder
# Remove-Item $tempFolder -Recurse