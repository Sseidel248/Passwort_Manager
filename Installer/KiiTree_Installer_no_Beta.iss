; Script generated by the Inno Script Studio Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppVersion "1.0.0"
#define MyAppBuild "6"
#define MyAppName "KiiTree"
#define MyName "Sebastian Seidel"

[Setup]
AppName = {#MyAppName}
AppPublisher = Sebastian Seidel
AppCopyright=Sebastian Seidel
DefaultDirName = {sd}\{#MyAppName}
//verhindert ein anzeigen der Startmen�gruppe
DisableProgramGroupPage = yes
DefaultGroupName = {#MyAppName}
;WizardImageFile = "..\Bilder\InstallLogo_test_164x314.bmp" 
AppVersion= {#MyAppVersion}.{#MyAppBuild}
VersionInfoProductVersion={#MyAppVersion}.{#MyAppBuild}
VersionInfoVersion = {#MyAppVersion}.{#MyAppBuild}
AppVerName = KiiTree {#MyAppVersion}.{#MyAppBuild}
OutputBaseFilename = {#MyAppName}_{#MyAppVersion}.{#MyAppBuild}
OutputDir = ..\Installer\
VersionInfoCompany=Sebastian Seidel
VersionInfoCopyright=Sebastian Seidel
VersionInfoProductName=KiiTree
VersionInfoProductTextVersion=Release
WizardStyle=modern
AppContact=sseidel248@yahoo.de
DisableWelcomePage = false
;LicenseFile=..\license.txt
InfoBeforeFile=..\README.md
//damit werden Netzwerke sichtbar
PrivilegesRequired=lowest
//zeigt die Seite wo der User aussucht wohin er es installieren m�chte
DisableDirPage = auto
AlwaysShowDirOnReadyPage = yes
UninstallDisplayIcon = {app}\Bilder\KiiTree_v1.ico
UninstallDisplayName = {#MyAppName} {#MyAppVersion}.{#MyAppBuild}

//zum eintragen von Organisation etc.
;UserInfoPage = true

[Files]
Source: "..\Release\KiiTree.exe"; DestDir: "{app}\Anwendung"; Flags: ignoreversion
Source: "..\DB\EmtyTable.xml"; DestDir: "{app}\DB"; Flags: ignoreversion

Source: "..\Bilder\KiiTree_v1.ico"; DestDir: "{app}\Bilder"; Flags: ignoreversion
Source: "..\README.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\VerionInfo.txt"; DestDir: "{app}\Anwendung"; Flags: ignoreversion
;Source: "..\Bilder\InstallLogo_test_164x314.bmp"; DestDir: "{app}"; Flags: deleteafterinstall
;Source: "..\Release\KiiTree.ini"; DestDir: "{app}"
Source: "..\license.txt"; DestDir: "{app}"

[Icons]
Name: "{group}\KiiTree"; Filename: "{app}\Anwendung\KiiTree.exe"; WorkingDir: "{app}\Bilder"; IconFilename: "{app}\Bilder\KiiTree_v1.ico"; IconIndex: 0
Name: "{userdesktop}\KiiTree"; Filename: "{app}\Anwendung\KiiTree.exe"; IconFilename: "{app}\Bilder\KiiTree_v1.ico"; IconIndex: 0; Tasks: Desktop_Icon
Name: "{userappdata}\MicrosoftInternetExplorerQuickLaunchTest"; Filename: "{app}\Anwendung\KiiTree.exe"; IconFilename: "{app}\Bilder\KiiTree_v1.ico"; IconIndex: 0; Tasks: quicklaunchicon

[Dirs]
Name: "{app}\DB"
Name: "{app}\Bilder"
Name: "{app}\Anwendung"
Name: "{userdocs}\KiiTree"

[INI]
; Imported INI File: "D:\Delphi embarcadero\Passwort_Manager\README.md"

[Tasks]
Name: "Desktop_Icon"; Description: "Desktop-Verkn�pfung Erstellen"; GroupDescription: "Additional Icon"
Name: "quicklaunchicon"; Description: "Startmen�-Eintrag erstellen"; GroupDescription: "Additional Icon"

[InstallDelete]
Type: files; Name: "{app}\KiiTree_v1.ico"

[UninstallDelete]
Type: dirifempty; Name: "{app}"
Type: files; Name: "{app}\Anwendung\KiiTree.ini"

[Languages]
Name: "German"; MessagesFile: "compiler:Languages\German.isl"

[Messages]
BeveledLabel={#MyAppName} {#MyAppVersion} � 2021 {#MyName}

[Code]
var
UsagePage: TInputOptionWizardPage;
InputDirWizardPage: TInputDirWizardPage;

procedure VergleicheVersion;
var
path,
Version,
VersionNew : String;
begin
  path := ExpandConstant( '{app}' );
  GetVersionNumbersString( path +'\Anwendung\KiiTree.exe', Version );
  VersionNew := '{#MyAppVersion}.{#MyAppBuild}';

  if CompareStr( Version, VersionNew ) < 0  then
    MsgBox( Version + ' < ' + VersionNew, mbInformation, MB_OK )
  else
    MsgBox( Version + ' >= ' + VersionNew, mbInformation, MB_OK );
end;

procedure InitializeWizard;
begin
  { Create the pages }
   UsagePage := CreateInputOptionPage(wpWelcome,
    'Benutzerinformation', 'Wie soll Kiitree eingerichtet werden?',
    'Bitte geben Sie an, wie Sie Kiitree verwenden m�chten, und klicken Sie dann auf Weiter.',
    True, False);
  UsagePage.Add('Lokalen Speicherort verwenden (Verwendung nur auf diesem PC)');
  UsagePage.Add('Serverpfad verwenden (Verwendung im Netzwerk)');

  InputDirWizardPage := CreateInputDirPage(UsagePage.ID, 'Serverpfad', 'W�hlen Sie einen Serverpfad in dem die Benutzer angelegt werden sollen.', '', False, 'AKiiTreeFolder');
  InputDirWizardPage.Add('Serverpfad:');
  InputDirWizardPage.Values[0] := '?:\';

   case GetPreviousData('UsageMode', '') of
    'Lokal': UsagePage.SelectedValueIndex := 0;
    'Server': UsagePage.SelectedValueIndex := 1;
  else
    UsagePage.SelectedValueIndex := 0;
  end;
end;

procedure RegisterPreviousData(PreviousDataKey: Integer);
var
  UsageMode: String;
begin
  { Store the settings so we can restore them next time }
  case UsagePage.SelectedValueIndex of
    0: UsageMode := 'Lokal';
    1: UsageMode := 'Server';
  end;
  SetPreviousData(PreviousDataKey, 'UsageMode', UsageMode);
  SetPreviousData(PreviousDataKey, 'ServerDir', InputDirWizardPage.Values[0]);
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
  { Skip pages that shouldn't be shown }
  if (PageID = InputDirWizardPage.ID) and (UsagePage.SelectedValueIndex = 0) then
    Result := True
  else
    Result := False;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var
  I: Integer;
begin
  { Validate certain pages before allowing the user to proceed }
  if CurPageID = InputDirWizardPage.ID then 
  begin
    if InputDirWizardPage.Values[0] = '' then 
    begin
      Result := False;
    end 
    else
    if DirExists(InputDirWizardPage.Values[0]) then 
    begin
      Result := False;
    end
    else
    begin
      Result := true;
    end;
  end;
  Result := true; 
end;



//wird ausgef�hrt bevor das Setup startet
{
function InitializeSetup(): Boolean;
var
str : String;
begin
  VergleicheVersion;
  Result := true;
end;
}



//wird ausgel�st bevor alles verarbeitet wird, also der gr�ne ladebalken kommt
procedure CurPageChanged(CurPageID: Integer);
var
str : String;
IniFileName: string;
begin
  if CurPageID = wpSelectDir then
  begin
    str := 'Wichtiger Hinweis!' + #10#13 + #10#13
    + 'Wenn Sie das Programm unter dem Pfad: "C:\Programme\" oder "C:\Programm (x86)\" installieren, kann es zu Problemen mit der UAC (Benutzerrechteverwaltung) kommen, wodurch die Anwendung nur mit Administatorenrechte gestartet werden kann.';

    MsgBox( Str, mbInformation, MB_OK );
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  IniFileName: string;
begin
  if CurStep = ssPostInstall then
  begin
    IniFileName := ExpandConstant('{app}\Anwendung\KiiTree.ini');
    if GetPreviousData('UsageMode', '') = 'Server' then
    begin
      SetIniString('App', 'ServerUsed', InputDirWizardPage.Values[0], IniFileName);
    end;
  end;
end;

//wird beim den Pfaden und den aussuchen von dektop verkn�pfung und so aufgerufen

{function ShouldSkipPage( PageID: Integer ): Boolean;
var
str : String;
begin

  if ( PageID = wpSelectDir ) then 
  begin
    str := 'Wichtiger Hinweis!' + #10#13 + #10#13
    + 'Wenn Sie das Programm unter dem Pfad: "C:\Programme\" oder "C:\Programm (x86)\" installieren, kann es zu Problemen mit der UAC (Benutzerrechteverwaltung) kommen, wodurch die Anwendung nur mit Administatorenrechte gestartet werden kann.';

    MsgBox( Str, mbInformation, MB_OK );

  end;
end;}

