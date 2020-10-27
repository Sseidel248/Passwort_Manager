unit Global_PWM;

{******************************************************************************
Konstanten von "KiiTree"
Author: Sebastian Seidel

*******************************************************************************}

interface

uses
  ActiveX, ShellAPI, ShlObj, vcl.Dialogs, WinAPI.Windows, System.Classes, MidasLib,
  System.SysUtils, Vcl.StdCtrls;

type
  TUserData = record
    User : string;
    PW_Str : string;
    KTP_Name_MD5 : String;
    AutoSaveChecked : string;
    FontSize : String;
    SymbolSize : String;
    UserTheme : String;
    ZeitImSpeicher : String;
    procedure SaveUserData( Ini : TStringlist );
    procedure LoadUserData( ini : TStringList );
  end;

type
  TDefaultSettings = record
    DefaultSavePath : String;        // Speicherpfad der KTP's ..\PM_DB\
    DefaultDBPath : string;          // Standartpfad ..\DB\
    DefaultUserSavePath : String;    // Eigene Dateien\Dokumente\KiiTree
    procedure Init( AHandle : HWND );
  end;

type
  TMainINI = record
//    Ini : TStringList; // hatte ein Bug hervorgerufen wegen Zugriffsverletzung!
    IniPath : String;
    IsNewUserChecked : Boolean;
    LastLoadPath : String;
//    DefaultPath : String;
//    PersonalUserSavePath : String;   // z.B. C:\Users\<Name des Benutzers>\KiiTree\
    procedure CreateIfNotExist;
    procedure LoadSetting( var CBNewUser : TCheckBox; var Edit : TEdit );
    procedure SaveSetting;
  end;

const
  PM_PW = 'pW!M3Pw1gH,A!<3D';

  //ini des Users
  SC_USER           = 'User';
  SC_PW             = 'Password';
  SC_KTP            = 'KTP-File';
  SC_EXT            = '.KTP';
  SC_AUTOSAVE       = 'AutoSave';
  SC_FONTSIZE       = 'FontSize';
  SC_SYMBOLSIZE     = 'SymbolSIze';
  SC_THEMEN         = 'Themen';
  SC_ZEITIMSPEICHER = 'TimeInClipBrd';
  //ini des Users - Ende -
  //ini vom programm
  SC_FIRSTSTART     = '';
  SC_LASTKTPPATH    = 'LastKTPPath';
  SC_DEFAULTPATH    = 'DefaultPath';
  SC_NOT_USED       = 'Not_Used';
  //ini vom programm - Ende -
  //Feste Node Ordner
  SC_FAVORITEN    = 'Favoriten';
  SC_ALLE         = 'Alle';
  //DBEdit / Edit TextHints
  SC_BEZEICHNUNG  = 'Bezeichnung eingeben...';
  SC_BENUTZER     = 'Benutzername eingeben...';
  SC_PASSWORT     = 'Passwort eingeben...';
  SC_URL          = 'Internetseite eingeben...';
  SC_NOTIZ        = 'Ihre Notiz';
  SC_MASTER_PW    = 'Master-Passwort eingeben...';

  IC_GET_PERSONAL_FOLDER = CSIDL_PERSONAL;

  //mit CSIDL_PERSONAL Eigene Dateien Ordner
  //z.B. C:\Users\<Benutzername_PC>\
//function GetSpecialFolder(hWindow: HWND; Folder: Integer): String;

function GetActualSaveFile( AFileName : String ): String;

function GetActualSavePath : String;

var
  UserData    : TUserData;
//  MainIniPath : String;
//  PersonalFolder : String;
  DefaultSettings : TDefaultSettings;
  MainIni     : TMainINI;
//  EmptyXMLFile : String;

implementation

uses
  Main_PWM;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-21
-------------------------------------------------------------------------------}
function GetActualSaveFile( AFileName : String ): String;
begin
  if MainIni.LastLoadPath.Equals( SC_NOT_USED ) or MainIni.LastLoadPath.Equals( '' ) then
    Result := Concat( DefaultSettings.DefaultUserSavePath, AFileName )
  else
  begin //prüft ob der Pfad nöch existiert
//    if DirectoryExists( MainIni.LastLoadPath )  then
      Result := Concat( MainIni.LastLoadPath, AFileName )
//    else // wenn nicht nimm den Standartpfad
//      Result := Concat( DefaultSettings.DefaultUserSavePath, AFileName );
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-21
-------------------------------------------------------------------------------}
function GetActualSavePath : String;
begin
  Result := GetActualSaveFile( '' );
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-19
-------------------------------------------------------------------------------}
procedure TUserData.SaveUserData( Ini : TStringlist );
begin
  Ini.Values[SC_USER] := User;
  Ini.Values[SC_PW] := PW_Str;
  Ini.Values[SC_KTP] := KTP_Name_MD5;
  Ini.Values[SC_AUTOSAVE] := AutoSaveChecked;
  Ini.Values[SC_FONTSIZE] := FontSize;
  Ini.Values[SC_SYMBOLSIZE] := SymbolSize;
  Ini.Values[SC_THEMEN] := UserTheme;
//    IniList.Values[SC_LASTKTPPATH] := LastKTPPath;
  Ini.Values[SC_ZEITIMSPEICHER] := ZeitImSpeicher;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-19
-------------------------------------------------------------------------------}
procedure TUserData.LoadUserData( ini : TStringList );
begin
  with Main do
  begin
    CBAutoSave.Checked := StrToBoolDef( Ini.Values[SC_AUTOSAVE], false );
    RGSchriftgreosse.ItemIndex  := StrToIntDef( Ini.Values[SC_FONTSIZE], 1 );
    RGSymbole.ItemIndex := StrToIntDef( Ini.Values[SC_SYMBOLSIZE], 1 );
    CBThemen.ItemIndex := StrToIntDef( Ini.Values[SC_THEMEN], 0 );
    CBThemenChange( nil );
    CBZeitImSpeicher.ItemIndex := StrToIntDef( Ini.Values[SC_ZEITIMSPEICHER], 3 );
//    CBZeitImSpeicherChange( nil );
  end;

end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-14
-------------------------------------------------------------------------------}
function GetSpecialFolder(hWindow: HWND; Folder: Integer): String;
var
  pMalloc: IMalloc;
  pidl: PItemIDList;
  Path: PChar;
begin
  // get IMalloc interface pointer
  if (SHGetMalloc(pMalloc) <> S_OK) then
  begin
//    MessageBox(hWindow, 'Couldn''t get pointer to IMalloc interface.',
//               'SHGetMalloc(pMalloc)', 16);
    Result := '';
    Exit;
  end;

  // retrieve path
  SHGetSpecialFolderLocation(hWindow, Folder, pidl);
  GetMem(Path, MAX_PATH);
  SHGetPathFromIDList(pidl, Path);
  Result := ExtractFilePath( Path );
  FreeMem(Path);

  // free memory allocated by SHGetSpecialFolderLocation
  pMalloc.Free(pidl);
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-21
-------------------------------------------------------------------------------}
procedure TDefaultSettings.Init( AHandle : HWND );
begin
  DefaultSavePath := '..\PM_DB\';
  DefaultDBPath := '..\DB\EmtyTable.xml';
  DefaultUserSavePath := GetSpecialFolder( AHandle, IC_GET_PERSONAL_FOLDER ) + 'Documents\KiiTree\';
end;


{------------------------------------------------------------------------------
Author: Seidel 2020-10-14
-------------------------------------------------------------------------------}
procedure TMainINI.CreateIfNotExist;
var
ini : TStringList;
begin
  IniPath := ExtractFilePath( ParamStr( 0 ) ) + 'KiiTree.ini';
  //Eigenschaften der MainINI
  IsNewUserChecked := true;
  LastLoadPath := SC_NOT_USED;

  ini := TStringList.Create;
  try
    if FileExists( IniPath ) then//gibt es eine INI, dann lade sie
    begin
      ini.LoadFromFile( IniPath );
      IsNewUserChecked := StrToBoolDef( ini.Values[SC_FIRSTSTART], true );
      LastLoadPath := ini.Values[SC_LASTKTPPATH];
    end
    else //wenn es keine Gibt das erstell die INI
    begin
      ini.Values[SC_FIRSTSTART] := BoolToStr( IsNewUserChecked, true );  //standart auf neuer User = true
      ini.Values[SC_LASTKTPPATH] := LastLoadPath;             //standart Not_Used
      ini.SaveToFile( IniPath );
    end;
  finally
    ini.Free;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-20
-------------------------------------------------------------------------------}
procedure TMainINI.LoadSetting( var CBNewUser : TCheckBox; var Edit : TEdit );
var
LastPath : String;
ini : TStringList;
begin
  ini := TStringList.Create;
  try
    ini.LoadFromFile( IniPath );
  //für die Checkbox fpr neue Benutzer, immer wenn nichts drinsteht -> neuer User
    CBNewUser.Checked := StrToBoolDef( ini.Values[ SC_FIRSTSTART ], true );

  //für den zuletzt gewählten Pfad
    LastPath := ini.Values[ SC_LASTKTPPATH ];
    //prüfe ob der Pfad noch existiert
    if DirectoryExists( LastPath ) then
      Edit.Text := LastPath
    else //wenn der Pfad nicht mehr existiert dann setzt den Pfad auf standart zurück
    begin
      Edit.Text := DefaultSettings.DefaultUserSavePath;
      LastLoadPath := DefaultSettings.DefaultUserSavePath;
    end;
  finally
    ini.Free;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-14
-------------------------------------------------------------------------------}
procedure TMainINI.SaveSetting;
var
ini : TStringList;
begin
    ini := TStringList.Create;
  try
    ini.LoadFromFile( IniPath );
    ini.Values[ SC_FIRSTSTART ] := BoolToStr( IsNewUserChecked, true );
    if not LastLoadPath.equals( SC_NOT_USED ) then
      ini.Values[ SC_LASTKTPPATH ] := LastLoadPath;
    ini.SaveToFile( IniPath );
  finally
    ini.Free;
  end;
end;

end.
