; Inno Setup script for ThirdReel — produces one signed-ready installer
; .exe instead of shipping a raw folder of loose files. Built in CI via
; `iscc windows\installer\thirdreel.iss`, with the release build already
; present at build\windows\x64\runner\Release.
;
; MyAppVersion can be overridden from the command line with
; /DMyAppVersion=1.2.3 (CI does this, reading pubspec.yaml) so the
; installer's version always matches the build it packages.
#ifndef MyAppVersion
  #define MyAppVersion "1.0.0"
#endif

#define MyAppName "ThirdReel"
#define MyAppPublisher "Thirdsan"
#define MyAppExeName "thirdreel.exe"
#define ReleaseDir "..\..\build\windows\x64\runner\Release"

[Setup]
AppId={{3BBB61A9-F42A-4CBF-A010-F5868B128EC3}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
UninstallDisplayIcon={app}\{#MyAppExeName}
OutputDir=..\..\build\windows\installer
OutputBaseFilename=ThirdReel-Setup
SetupIconFile=..\runner\resources\app_icon.ico
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
; Machine-wide install (Program Files) by default; falls back to a
; per-user install if the user declines the elevation prompt.
PrivilegesRequired=admin
PrivilegesRequiredOverridesAllowed=dialog
DisableProgramGroupPage=yes
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; GroupDescription: "Additional shortcuts:"

[Files]
Source: "{#ReleaseDir}\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs ignoreversion

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\Uninstall {#MyAppName}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Launch {#MyAppName}"; Flags: nowait postinstall skipifsilent
