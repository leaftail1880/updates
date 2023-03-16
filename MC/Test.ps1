$path = "C:\Windows\System32\Windows.ApplicationModel.Store.dll"

Stop-Process -Name WinStore.App -ErrorAction SilentlyContinue
takeown /f "$path"
icacls "$path" /grant *S-1-3-4:F /c
Copy-Item -Path $path -Destination "C:\"
Copy-Item -Path "C:\Windows.ApplicationModel.Store.dll" -Destination $path