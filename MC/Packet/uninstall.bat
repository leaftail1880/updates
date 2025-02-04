chcp 437

set "DLL=Windows.ApplicationModel.Store.dll"
set "Log=setup-log.txt"

del %Log%

set "Original=%CD%\original"
mkdir "%Original%" >> %Log%

takeown /f "C:\Windows\System32\%DLL%" >> %Log% 
icacls "C:\Windows\System32\%DLL%" /grant *S-1-3-4:F /c >> %Log%
copy /Y "%Original%\System32\%DLL%" "C:\Windows\System32\" /V >> %Log%

takeown /f "C:\Windows\SysWOW64\%DLL%" >> %Log% 
icacls "C:\Windows\SysWOW64\%DLL%" /grant *S-1-3-4:F /c >> %Log%
copy /Y "%Original%\SysWOW64\%DLL%" "C:\Windows\SysWOW64\" /V >> %Log%

@REM del /Q /S "%CD%\temp"
@REM del /Q "%CD%\setup.bat"