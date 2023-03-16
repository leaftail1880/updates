$name = (Get-Process -Id $PID).StartInfo.EnvironmentVariables["USERNAME"]

$path = "C:\Windows\System32\Windows.ApplicationModel.Store.dll"

takeown /F $path /A /R /D Y 
icacls $path /grant ${name}:(OI)(CI)F /T

Copy-Item -Path $path -Destination "C:\"
Copy-Item -Path "C:\Windows.ApplicationModel.Store.dll" -Destination $path