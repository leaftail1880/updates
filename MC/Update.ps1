Add-Type -AssemblyName PresentationFramework

$tempFolder = New-Item -ItemType Directory -Path $env:TEMP\MCDownload
$tempPath = $tempFolder.FullName

function LogErrorAndExit($ErrorType, $ErrorToLog) {

  # Check if running as administrator
  $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

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

Admin: $isAdmin
System: $systemType

Error:
$ErrorToLog
"@

  # Write file
  Set-Content -Path "$env:USERPROFILE\Desktop\MCDownloadErrorlog.txt" -Value $logContent
  Write-Host "Script failed. Check error boxes under another windows."
  # Show error box
  [System.Windows.MessageBox]::Show("$ErrorType error. Check desktop for detailed log")
  Exit 1
}

function DownloadArchieve($Uri, $FileName) {
  $file = "$tempPath\$FileName"

  Invoke-WebRequest -Uri $Uri -OutFile $file
  Expand-Archive -Path $file -DestinationPath $tempPath
  Remove-Item -Path $file -Force
}



# Use the temp folder
Write-Output "Using temp folder $($tempPath)"

$file = "$tempPath\DLL.zip"

try {
  DownloadArchieve "https://raw.githubusercontent.com/leaftail1880/updates/main/MC/DLL.zip" "DLL.zip"

  $stupidDLLname = "Windows.ApplicationModel.Store.dll"

  try {
    takeown /f "$env:SystemRoot/System32/$stupidDLLname" /a
    Copy-Item -Path "$tempPath/DLL/System32/$stupidDLLname" -Destination "$env:SystemRoot/System32/$stupidDLLname"
  }
  catch {
    LogErrorAndExit "Patching System32" $Error
  }
    
  try {
    takeown /f "$env:SystemRoot/SysWOW64/$stupidDLLname" /a
    Copy-Item -Path "$tempPath/DLL/SysWOW64/$stupidDLLname" -Destination "$env:SystemRoot/SysWOW64/$stupidDLLname"
  }
  catch {
    LogErrorAndExit "Patching System32" $Error
  }

  DownloadArchieve "https://github.com/MCMrARM/mc-w10-version-launcher/releases/download/0.4.0/MCLauncher.zip" "MCLauncher.zip"
}
catch {
  LogErrorAndExit "Unhandled" $Error  
}


# Delete the temp folder
Remove-Item $tempFolder -Recurse