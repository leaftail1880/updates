$path = "C:\Windows\System32\Windows.ApplicationModel.Store.dll"

Start-Process cmd -ArgumentList "/c takeown /f "$path" && icacls "$path" /grant *S-1-3-4:F /t /c /l" -Verb runAs\
Copy-Item -Path $path -Destination "C:\"
Copy-Item -Path "C:\Windows.ApplicationModel.Store.dll" -Destination $path