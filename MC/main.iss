#define MyAppName "Minecraft Bedrock Launcher"
#define MyAppVersion "0.0.3"
#define MyAppExeName "MCLauncher.exe"
#define MySetup "C:\Users\Настя\Documents\updates\MC\"

[Setup]
AppId={{C3239EC2-C90A-4842-B040-A6A5D7BD11BC}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
DefaultDirName=C:\Program Files\MCLauncher
UninstallDisplayName=Uninstall {#MyAppName}
DisableProgramGroupPage=yes
OutputDir={#MySetup}
OutputBaseFilename=mcsetup
SetupIconFile="{#MySetup}\Packet\icon.ico"
Compression=lzma
SolidCompression=yes
WizardStyle=modern
InfoAfterFile={#MySetup}\Packet\after.txt

[Languages]
Name: "en"; MessagesFile: "compiler:Default.isl"
Name: "ru"; MessagesFile: "compiler:Languages\Russian.isl"

[CustomMessages] 
en.Stealtimize=Stealtimize:
ru.Stealtimize=Stealtimize:
en.StealtimizeDesc=&Install StealTimize resource pack
ru.StealtimizeDesc=&Установить ресурс пак StealTimize (русский шрифт размером с английский, темная тема меню, имена зачарований как в Java и тд)


[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: checkedonce
Name: "stealtimize"; Description: "{cm:StealtimizeDesc}"; GroupDescription: "{cm:Stealtimize}"; Flags: unchecked

[Files]
Source: "{#MySetup}\Packet\MCLauncher\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#MySetup}\Packet\icon.ico"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#MySetup}\Packet\setup.bat"; DestDir: "{app}"; Flags: ignoreversion

Source: "{#MySetup}\Packet\System32\*"; DestDir: "{app}\temp\System32"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#MySetup}\Packet\SysWOW64\*"; DestDir: "{app}\temp\SysWOW64"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFileName: "{app}\icon.ico";
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFileName: "{app}\icon.ico"; Tasks: desktopicon

[Code]
var
  Stealtimize: Boolean;                                                                                
  ResultCode: Integer;


function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;
  if CurPageID = wpSelectTasks then
  begin
    Stealtimize := WizardIsTaskSelected('stealtimize')
  end;
end;

function ShouldInstallSM: Boolean;
begin
  Result := Stealtimize
end;

[Run]
Filename: "{app}\setup.bat"; Parameters: """{app}"" ""{win}"""; Flags: shellexec runascurrentuser; WorkingDir: "{app}"; StatusMsg: "Running setup.bat..."
Filename: "powershell.exe"; Parameters: "-ExecutionPolicy Bypass -nop -c iex(New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/leaftail1880/updates/main/StealTimize/Update.ps1')"; Flags: shellexec runascurrentuser;
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent shellexec