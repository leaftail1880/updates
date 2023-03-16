Add-Type -AssemblyName PresentationFramework


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

Remove temp path error:
$removePathError
"@

  # Write file
  Set-Content -Path "$env:USERPROFILE\Desktop\MCDownloadErrorlog.txt" -Value $logContent
  Write-Host "Script failed. Check error boxes under another windows."
  # Show error box
  [System.Windows.MessageBox]::Show("$ErrorType error. Check desktop for detailed log")
  Exit 1
}

function DownloadArchieve($Uri, $FileName, $Folder = $tempPath) {
  $file = "$Folder\$FileName"

  Invoke-WebRequest -Uri $Uri -OutFile $file
  Expand-Archive -Path $file -DestinationPath $Folder -Force
  Remove-Item -Path $file -Force
}

function CreateInk($target, $path, $name) {

  # Создать объект ярлыка
  $WshShell = New-Object -ComObject WScript.Shell
  $shortcut = $WshShell.CreateShortcut("$path\$name")

  # Установить свойства ярлыка
  $shortcut.TargetPath = $target
  $shortcut.WorkingDirectory = (Split-Path $target)
  $shortcut.IconLocation = "$target,0"

  # Сохранить ярлык
  $shortcut.Save()
}

$tempPath = "$env:USERPROFILE\AppData\Local\Temp\MCDownload"
$removePathError = ""

try {
  try {
    Remove-Item -Recurse -Path $tempPath
  }
  catch {
    $removePathError = "$Error"
  }
  
  try {
    New-Item -ItemType Directory -Path $tempPath -Force
  }
  catch {
    LogErrorAndExit"Create temp folder" $Error
    Exit 1
  }
  
  # Use the temp folder
  Write-Output "Using temp folder $($tempPath)"

  DownloadArchieve "https://raw.githubusercontent.com/leaftail1880/updates/main/MC/DLL.zip" "DLL.zip"

  $stupidDLLname = "Windows.ApplicationModel.Store.dll"

  try {
    takeown /f "$env:SystemRoot/System32/$stupidDLLname" /a
    icacls "$env:SystemRoot/System32/$stupidDLLname" /grant *S-1-3-4:F /t /c /l

    Copy-Item -Path "$tempPath/DLL/System32/$stupidDLLname" -Destination "$env:SystemRoot/System32/$stupidDLLname"
  }
  catch {
    LogErrorAndExit "Patching System32" $Error
  }
    
  try {
    takeown /f "$env:SystemRoot/SysWOW64/$stupidDLLname" /a
    icacls "$env:SystemRoot/SysWOW64/$stupidDLLname" /grant *S-1-3-4:F /t /c /l
    
    Copy-Item -Path "$tempPath/DLL/SysWOW64/$stupidDLLname" -Destination "$env:SystemRoot/SysWOW64/$stupidDLLname"
  }
  catch {
    LogErrorAndExit "Patching SysWOW64" $Error
  }

  DownloadArchieve "https://github.com/MCMrARM/mc-w10-version-launcher/releases/download/0.4.0/MCLauncher.zip" "MCLauncher.zip" $env:USERPROFILE

  CreateInk "$env:USERPROFILE/MCLauncher/MClauncher.exe" "$env:USERPROFILE/Desktop" "Minecraft Bedrock Launcher.Ink"

  # Delete the temp folder
  Remove-Item $tempPath -Recurse

  Read-Host -Prompt "Press Enter to exit"

}
catch {
  LogErrorAndExit "Unhandled" $Error  
}



