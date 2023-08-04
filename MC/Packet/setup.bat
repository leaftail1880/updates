chcp 437

set "app=%~1"
set "win=%~2"
set "DLL=Windows.ApplicationModel.Store.dll"
set "Log=setup-log.txt"

del %Log%
taskkill /f /im WinStore.App.exe >> %Log% 
takeown /f %win%\System32\%DLL% >> %Log% 
icacls %win%\System32\%DLL% /grant *S-1-3-4:F /c >> %Log%
copy "%app%\temp\System32\%DLL%" "%win%\System32\" >> %Log%
takeown /f %win%\SysWOW64\%DLL% >> %Log% 
icacls %win%\SysWOW64\%DLL% /grant *S-1-3-4:F /c >> %Log%
copy "%app%\temp\SysWOW64\%DLL%" "%win%\SysWOW64\" >> %Log%
del /Q /S "%app%\temp"
del /Q "%app%\setup.bat"