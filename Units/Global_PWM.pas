unit Global_PWM;

{******************************************************************************
Konstanten von "KiiTree"
Author: Copyleft 2020 - 2021 Sebastian Seidel

*******************************************************************************}

interface

uses
  ActiveX, ShellAPI, ShlObj, vcl.Dialogs, WinAPI.Windows, System.Classes, MidasLib,
  System.SysUtils, Vcl.StdCtrls, Edit4User, Vcl.ComCtrls;

type
  TUserData = record
  public
    //Userbezogen
    User : string;
    PW_Str : string;
    KTP_Name_MD5 : String;
    //Darstellung
    UserTheme : Integer;
    FontSize : Integer;
    DesignNr : Integer;
    //Allgemein
    ZeitImSpeicher : Integer;
    AutoSaveChecked : Boolean;
    FocusEditAfterNewKii : Boolean;//Change: Seidel 2020-10-28
    MultiSelect : Boolean;//Change: Seidel 2021-02-03
    ShowHints : Boolean;//Change: Seidel 2021-02-03
    procedure InitUserData( const Name, PW, KTPFile : String );
    procedure AddInKTP( var Ini : TStringlist );
    procedure LoadUserSettings( var ini : TStringlist ); overload;
    procedure LoadUserSettings( ); overload;

//    procedure SaveUserData( Ini : TStringlist );
//    procedure SetUserTheme( Value : String );
//    procedure SetFontSize( Value : String );
//    procedure LoadUserData( ini : TStringList );
  private
    Version : String;
    function CheckVersionNr( const Now : String ) : Boolean;
    procedure UpdateUserIni( var ini : TStringlist );
    procedure ReadIni( const Ini : TStringlist );
    procedure SetEntryInVars( var Var1 : String; const Key : String; const ini : TStringList ); overload;
    procedure SetEntryInVars( var Var1 : Integer; const Key : String; const ini : TStringList ); overload;
    procedure SetEntryInVars( var Var1 : Boolean; const Key : String; const ini : TStringList ); overload;
    function CheckEntry( const Key : String; var ini : TStringList ) : Boolean;
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
    IniPath : String;
    IsNewUserChecked : Boolean;
    LastLoadPath : String;
    LastUser : String;
    IsLastUserAgainChecked : Boolean;
    ServerSavePath : String;
    function CreateIfNotExist: Boolean;
    function GetUserPathIndex: Integer;
    procedure LoadSetting( var CBNewUser, CBMerkeUser : TCheckBox;
                                var ComboBoxExPath: TComboBoxEx;
                                var EditUser: TEdit4User );
    procedure SaveSetting;
  private
    function CheckWriteAccessAndSave( const ini : TStringList; forCreate : Boolean = false ): Boolean;
    procedure SaveReadOnly( const ini : TStringList );
  end;

const
  PM_PW = 'pW!M3Pw1gH,A!<3D';
  SC_EXT            = '.KTP';

  IC_ROW_HEAD       = 0;
  IC_COL_BEZ        = 0;
  IC_COL_PWD        = 1;
  IC_COL_ERG        = 2;

  //ini des Users
  SC_VERSION          = 'Version';
  SC_USER             = 'User';
  SC_PW               = 'Password';
  SC_KTP              = 'KTP-File';
  SC_AUTOSAVE         = 'AutoSave';
  SC_SHOWHINTS        = 'ShowHints';
  SC_MULITSEL         = 'MultiSel';
  SC_DESIGN           = 'Design';
  SC_FONTSIZE         = 'FontSize';
  SC_THEMEN           = 'Themen';
  SC_ZEITIMSPEICHER   = 'TimeInClipBrd';
  SC_FOCUSAFTERCREATE = 'FocusEditAfterCreate';
  //ini des Users - Ende -

  //ini vom programm
  SC_SEC            = '[App]';
  SC_FIRSTSTART     = 'First_Start';
  SC_LASTKTPPATH    = 'LastKTPPath';
  SC_DEFAULTPATH    = 'DefaultPath';
  SC_LASTUSER       = 'LastUser';
  SC_ISLASTUSERCHK  = 'IsLastUserChecked';
  SC_NOT_USED       = 'Not_Used';
  SC_SERVERUSED     = 'ServerUsed';
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

function GetMyVersion: string;

var
  UserData    : TUserData;
  DefaultSettings : TDefaultSettings;
  MainIni     : TMainINI;

implementation

uses
  Main_PWM,
  Messages_PWM;
{------------------------------------------------------------------------------
Author: Seidel 2021-02-04
-------------------------------------------------------------------------------}
function IsFileReadOnly(const FileName: string): Boolean;
var
srec: TSearchRec;
begin
  Result:=false;
  if FindFirst(FileName, faAnyFile, srec) = 0 then
  begin
    try
      if (srec.Attr and faReadOnly)>0 then
        Result := true //Schreibgesch. Datei
    finally
      FindClose(srec);
    end;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-21
-------------------------------------------------------------------------------}
function GetActualSaveFile( AFileName : String ): String;
begin
  if MainIni.LastLoadPath.Equals( SC_NOT_USED ) or MainIni.LastLoadPath.Equals( '' ) then
    Result := Concat( DefaultSettings.DefaultUserSavePath, AFileName )
  else
  begin
    //Change: Seidel 2021-01-28
    if pos( MainIni.LastLoadPath, '\', Length( MainIni.LastLoadPath )-2 ) = Length( MainIni.LastLoadPath ) then
      Result := Concat( MainIni.LastLoadPath, AFileName )
    else
      Result := Concat( MainIni.LastLoadPath, '\', AFileName )
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
Author: Seidel 2020-10-17
von: www.swissdelphicenter.ch
-------------------------------------------------------------------------------}
function GetMyVersion: string;
var
  VerInfoSize: DWORD;
  VerInfo: Pointer;
  VerValueSize: DWORD;
  VerValue: PVSFixedFileInfo;
  Dummy: DWORD;
begin
  Result := '';
  VerInfoSize := GetFileVersionInfoSize(PChar(ParamStr(0)), Dummy);
  if VerInfoSize = 0 then Exit;
  GetMem(VerInfo, VerInfoSize);
  GetFileVersionInfo(PChar(ParamStr(0)), 0, VerInfoSize, VerInfo);
  VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize);
  with VerValue^ do
  begin
    Result := IntToStr(dwFileVersionMS shr 16);
    Result := Result + '.' + IntToStr(dwFileVersionMS and $FFFF);
    Result := Result + '.' + IntToStr(dwFileVersionLS shr 16);
    Result := Result + '.' + IntToStr(dwFileVersionLS and $FFFF);
  end;
  FreeMem(VerInfo, VerInfoSize);
end;

{------------------------------------------------------------------------------
Author: Seidel 2021-02-05
-------------------------------------------------------------------------------}
procedure TUserData.InitUserData( const Name, PW, KTPFile : String );
begin
  //Aktuelle Version von Kiitree
  Version := GetMyVersion;
  //Benutzerbezogen
  User := Name;
  PW_Str := PW;
  KTP_Name_MD5 := KTPFile;
  //Einstellungen
  UserTheme := 0;
  FontSize := 1;
  DesignNr := 0;
  //Allgemein
  ZeitImSpeicher := 3;
  AutoSaveChecked := false;
  FocusEditAfterNewKii := false;
  MultiSelect := false;
  ShowHints := true;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-19
-------------------------------------------------------------------------------}
//procedure TUserData.SaveUserData( Ini : TStringlist );
//begin
//  //Aktuelle Version von Kiitree
//  Ini.Values[SC_VERSION] := Version;
//  //Benutzerbezogen
//  Ini.Values[SC_USER] := User;
//  Ini.Values[SC_PW] := PW_Str;
//  Ini.Values[SC_KTP] := KTP_Name_MD5;
//  //Einstellungen
//  Ini.Values[SC_THEMEN] := IntToStr( UserTheme );
//  Ini.Values[SC_DESIGN] := IntToStr( DesignNr );
//  Ini.Values[SC_FONTSIZE] := IntToStr( FontSize );
//  //Allgemein
//  Ini.Values[SC_ZEITIMSPEICHER] := IntToStr( ZeitImSpeicher );
//  Ini.Values[SC_FOCUSAFTERCREATE] := BoolToStr( FocusEditAfterNewKii, true );
//  Ini.Values[SC_AUTOSAVE] := BoolToStr( AutoSaveChecked, true );
//  Ini.Values[SC_SHOWHINTS] := BoolToStr( ShowHints, true );
//  Ini.Values[SC_MULITSEL] := BoolToStr( MultiSelect, true );
//end;

{------------------------------------------------------------------------------
Author: Seidel 2021-02-05
-------------------------------------------------------------------------------}
procedure TUserData.AddInKTP( var Ini : TStringlist );
begin
  //Aktuelle Version von Kiitree
  Ini.Values[SC_VERSION] := Version;
  //Benutzerbezogen
  Ini.Values[SC_USER] := User;
  Ini.Values[SC_PW] := PW_Str;
  Ini.Values[SC_KTP] := KTP_Name_MD5;
  //Einstellungen
  Ini.Values[SC_THEMEN] := IntToStr( UserTheme );
  Ini.Values[SC_DESIGN] := IntToStr( DesignNr );
  Ini.Values[SC_FONTSIZE] := IntToStr( FontSize );
  //Allgemein
  Ini.Values[SC_ZEITIMSPEICHER] := IntToStr( ZeitImSpeicher );
  Ini.Values[SC_AUTOSAVE] := BoolToStr( AutoSaveChecked, true );
  Ini.Values[SC_FOCUSAFTERCREATE] := BoolToStr( FocusEditAfterNewKii, true );
  Ini.Values[SC_SHOWHINTS] := BoolToStr( ShowHints, true );
  Ini.Values[SC_MULITSEL] := BoolToStr( MultiSelect, true );
end;

{------------------------------------------------------------------------------
Author: Seidel 2021-02-05
-------------------------------------------------------------------------------}
procedure TUserData.LoadUserSettings( var ini : TStringlist );
var
VersionNow : String;
States : TMainStates;
begin
  VersionNow := GetMyVersion;
  with Main do
  begin
    DoChangeStates( [msLoadUserData] );
    //Ini Einträge in die Userdata Variablen packen
    ReadIni( ini );

    //Aktuelle Version von Kiitree mit Userdata Version vergleichen
    if CheckVersionNr( VersionNow ) then
      UpdateUserIni( ini );

    //Einstellungen
    if StrToIntDef( Ini.Values[SC_DESIGN], 0 ) = 0 then
    begin
      CBDunkel.Checked := false;
      CBHell.Checked := true;
    end
    else
    begin
      CBDunkel.Checked := true;
      CBHell.Checked := false;
    end;
    CBThemen.ItemIndex := StrToIntDef( Ini.Values[SC_THEMEN], 0 );
    CBThemenChange( nil );
    //FONTSIZE hinzufügen

    //Allgemein
    CBZeitImSpeicher.ItemIndex := StrToIntDef( Ini.Values[SC_ZEITIMSPEICHER], 3 );

    CBAutoSave.Checked := StrToBoolDef( Ini.Values[SC_AUTOSAVE], false );
    if CBAutoSave.Checked then
      States := States + [msAutoSave];

    CBEditAfterCreateNewKii.Checked := StrToBoolDef( Ini.Values[SC_FOCUSAFTERCREATE], false );
    if CBEditAfterCreateNewKii.Checked then
      States := States + [msEditAfterNewKiiCreate];

    CBMehrfachAuswahl.Checked := StrToBoolDef( Ini.Values[SC_MULITSEL], false );
    if CBMehrfachAuswahl.Checked then
      States := States + [msMultiSel];

    CBShowMessages.Checked := StrToBoolDef( Ini.Values[SC_SHOWHINTS], true );
    if CBShowMessages.Checked then
      States := States + [msShowMinimizeHint];

    DoChangeStates( States, [msLoadUserData] );
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2021-02-10 laden der Initialisierungwerte
-------------------------------------------------------------------------------}
procedure TUserData.LoadUserSettings( );
var
States : TMainStates;
begin
  with Main do
  begin
    DoChangeStates( [msLoadUserData] );

    //Einstellungen
    if Self.DesignNr = 0 then
    begin
      CBDunkel.Checked := false;
      CBHell.Checked := true;
    end
    else
    begin
      CBDunkel.Checked := true;
      CBHell.Checked := false;
    end;
    CBThemen.ItemIndex := Self.UserTheme;
    CBThemenChange( nil );
    //FONTSIZE hinzufügen

    //Allgemein
    CBZeitImSpeicher.ItemIndex := Self.ZeitImSpeicher;

    CBAutoSave.Checked := Self.AutoSaveChecked;
    if CBAutoSave.Checked then
      States := States + [msAutoSave];

    CBEditAfterCreateNewKii.Checked := Self.FocusEditAfterNewKii;
    if CBEditAfterCreateNewKii.Checked then
      States := States + [msEditAfterNewKiiCreate];

    CBMehrfachAuswahl.Checked := Self.MultiSelect;
    if CBMehrfachAuswahl.Checked then
      States := States + [msMultiSel];

    CBShowMessages.Checked := Self.ShowHints;
    if CBShowMessages.Checked then
      States := States + [msShowMinimizeHint];

    DoChangeStates( States, [msLoadUserData] );
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2021-02-05
-------------------------------------------------------------------------------}
function TUserData.CheckVersionNr( const Now : String ) : Boolean;
begin
  if Version.Equals( Now ) then //Version gleich
    Result := false
  else
  if Version.Equals( '' ) then  //Version noch nicht gesetzt
    Result := true
  else
  if Version < Now then         //Userini älter
    Result := true
  else                          //Userini neuer
    Result := false;
end;

{------------------------------------------------------------------------------
Author: Seidel 2021-02-05
-------------------------------------------------------------------------------}
procedure TUserData.UpdateUserIni( var ini : TStringlist );
begin
  //Einstellungen
  if CheckEntry( SC_THEMEN, ini ) then
    Ini.Values[SC_THEMEN] := IntToStr( UserTheme );
  if CheckEntry( SC_DESIGN, ini ) then
    Ini.Values[SC_DESIGN] := IntToStr( DesignNr );
  if CheckEntry( SC_FONTSIZE, ini ) then
    Ini.Values[SC_FONTSIZE] := IntToStr( FontSize );
  //Allgemein
  if CheckEntry( SC_ZEITIMSPEICHER, ini ) then
    Ini.Values[SC_ZEITIMSPEICHER] := IntToStr( ZeitImSpeicher );
  if CheckEntry( SC_AUTOSAVE, ini ) then
    Ini.Values[SC_AUTOSAVE] := BoolToStr( AutoSaveChecked, true );
  if CheckEntry( SC_FOCUSAFTERCREATE, ini ) then
    Ini.Values[SC_FOCUSAFTERCREATE] := BoolToStr( FocusEditAfterNewKii, true );
  if CheckEntry( SC_SHOWHINTS, ini ) then
   Ini.Values[SC_SHOWHINTS] := BoolToStr( ShowHints, true );
  if CheckEntry( SC_MULITSEL, ini ) then
   Ini.Values[SC_MULITSEL] := BoolToStr( MultiSelect, true );
end;

{------------------------------------------------------------------------------
Author: Seidel 2021-02-05
-------------------------------------------------------------------------------}
procedure TUserData.ReadIni( const Ini : TStringlist );
begin
  //Aktuelle Version von Kiitree
  SetEntryInVars( Version, SC_VERSION, ini );
  //Benutzerbezogen
  SetEntryInVars( User, SC_USER, ini );
  SetEntryInVars( PW_Str, SC_PW, ini );
  SetEntryInVars( KTP_Name_MD5, SC_KTP, ini );
  //Einstellungen
  SetEntryInVars( UserTheme, SC_THEMEN, ini );
  SetEntryInVars( DesignNr, SC_DESIGN, ini );
  SetEntryInVars( FontSize, SC_FONTSIZE, ini );
  //Allgemein
  SetEntryInVars( ZeitImSpeicher, SC_ZEITIMSPEICHER, ini );
  SetEntryInVars( AutoSaveChecked, SC_AUTOSAVE, ini );
  SetEntryInVars( FocusEditAfterNewKii, SC_FOCUSAFTERCREATE, ini );
  SetEntryInVars( ShowHints, SC_SHOWHINTS, ini );
  SetEntryInVars( MultiSelect, SC_MULITSEL, ini );
end;

{------------------------------------------------------------------------------
Author: Seidel 2021-02-05
-------------------------------------------------------------------------------}
procedure TUserData.SetEntryInVars( var Var1 : String; const Key : String; const ini : TStringList );
begin
  if not Ini.IndexOfName( Key ) = -1 then//ist der Eintrag vorhanden, dann
  begin
    if not ini.Values[Key].Equals('') then//ist der Eintrag nicht leer, dann
    begin
      Var1 := Ini.Values[Key];//schreibe den Eintrag in die Variable
    end;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2021-02-05
-------------------------------------------------------------------------------}
procedure TUserData.SetEntryInVars( var Var1 : Integer; const Key : String; const ini : TStringList );
begin
  if not Ini.IndexOfName( Key ) = -1 then
  begin
    if not ini.Values[Key].Equals('') then
    begin
      Var1 := StrToInt( Ini.Values[Key] );
    end;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2021-02-05
-------------------------------------------------------------------------------}
procedure TUserData.SetEntryInVars( var Var1 : Boolean; const Key : String; const ini : TStringList );
begin
  if not Ini.IndexOfName( Key ) = -1 then
  begin
    if not ini.Values[Key].Equals('') then
    begin
      Var1 := StrToBool( Ini.Values[Key] );
    end;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2021-02-05
-------------------------------------------------------------------------------}
function TUserData.CheckEntry( const Key : String; var ini : TStringList ) : Boolean;
begin
  Result := true; //muss neu gesetzt werden
  if not Ini.IndexOfName( Key ) = -1 then//Eintrag existiert
  begin
    if not ini.Values[Key].Equals('') then//Eintrag ist nicht leer
    begin
      Result := false;
    end;
  end;
end;
{------------------------------------------------------------------------------
Author: Seidel 2021-01-15
-------------------------------------------------------------------------------}
//procedure TUserData.SetUserTheme( Value : String );
//begin
//  Self.UserTheme := Value;
//  Main.DoChangeStates( [msChanged] );
//end;

{------------------------------------------------------------------------------
Author: Seidel 2021-01-15
-------------------------------------------------------------------------------}
//procedure TUserData.SetFontSize( Value : String );
//begin
//  Self.FontSize := Value;
//  Main.DoChangeStates( [msChanged] );
//end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-19
-------------------------------------------------------------------------------}
//procedure TUserData.LoadUserData( ini : TStringList );
//begin
//  with Main do
//  begin
//    DoChangeStates( [msLoadUserData] );
//    CBAutoSave.Checked := StrToBoolDef( Ini.Values[SC_AUTOSAVE], false );
////    RGSymbole.ItemIndex := StrToIntDef( Ini.Values[SC_SYMBOLSIZE], 1 );
//    CBMehrfachAuswahl.Checked := StrToBoolDef( Ini.Values[SC_MULITSEL], false );
//    CBShowMessages.Checked := StrToBoolDef( Ini.Values[SC_SHOWHINTS], true );
//    if StrToIntDef( Ini.Values[SC_DESIGN], 0 ) = 0 then
//    begin
//      CBDunkel.Checked := false;
//      CBHell.Checked := true;
//    end
//    else
//    begin
//      CBDunkel.Checked := true;
//      CBHell.Checked := false;
//    end;
//    CBThemen.ItemIndex := StrToIntDef( Ini.Values[SC_THEMEN], 0 );
//    CBThemenChange( nil );
//    CBZeitImSpeicher.ItemIndex := StrToIntDef( Ini.Values[SC_ZEITIMSPEICHER], 3 );
//    CBEditAfterCreateNewKii.Checked := StrToBoolDef( Ini.Values[SC_FOCUSAFTERCREATE], false );
//    DoChangeStates( [], [msLoadUserData] );
//  end;
//end;

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
function TMainINI.CreateIfNotExist : Boolean;
var
ini : TStringList;
begin
  Result := true;
  IniPath := ExtractFilePath( ParamStr( 0 ) ) + 'KiiTree.ini';
  //Eigenschaften der MainINI
  IsNewUserChecked := true;
  IsLastUserAgainChecked := false;
  LastLoadPath := SC_NOT_USED;
  LastUser := SC_NOT_USED;
  ServerSavePath := SC_NOT_USED;

  ini := TStringList.Create;
  try
    if FileExists( IniPath ) then//gibt es eine INI, dann lade sie
    begin
      ini.LoadFromFile( IniPath );
      IsNewUserChecked := StrToBoolDef( ini.Values[SC_FIRSTSTART], true );
      IsLastUserAgainChecked := StrToBoolDef( ini.Values[SC_ISLASTUSERCHK], true );
      LastLoadPath := ini.Values[SC_LASTKTPPATH];
      LastUser := ini.Values[SC_LASTUSER];
      ServerSavePath := ini.Values[SC_SERVERUSED];
    end
    else //wenn es keine Gibt das erstell die INI
    begin
      ini.Insert( 0 , SC_SEC );
      ini.Values[SC_FIRSTSTART] := BoolToStr( IsNewUserChecked, true );  //standart auf neuer User = true
      ini.Values[SC_ISLASTUSERCHK] := BoolToStr( IsLastUserAgainChecked, true );
      ini.Values[SC_LASTKTPPATH] := LastLoadPath;             //standart Not_Used
      ini.Values[SC_LASTUSER] := LastUser;
      ini.Values[SC_SERVERUSED] := ServerSavePath;
//    prüft ob Schreibrechte vorhanden sind und gibt Msg an den User
      if not CheckWriteAccessAndSave( ini, true ) then
        Result := false;
    end;
  finally
    ini.Free;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2021-01-26
-------------------------------------------------------------------------------}
function TMainINI.GetUserPathIndex: Integer;
begin
  if ServerSavePath.Equals( '' ) then
    Result := 3
  else
    Result := 5;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-20
-------------------------------------------------------------------------------}
procedure TMainINI.LoadSetting( var CBNewUser, CBMerkeUser : TCheckBox;
                                var ComboBoxExPath: TComboBoxEx;
                                var EditUser: TEdit4User );
var
LastPath, LastUserStr : String;
ini : TStringList;
i : Integer;
begin
  ini := TStringList.Create;
  try
    ini.LoadFromFile( IniPath );
  //für die Checkbox fpr neue Benutzer, immer wenn nichts drinsteht -> neuer User
    CBNewUser.Checked := StrToBoolDef( ini.Values[ SC_FIRSTSTART ], true );

    i := GetUserPathIndex;

  //für den zuletzt gewählten Pfad
    LastPath := ini.Values[ SC_LASTKTPPATH ];
    //prüfe ob der Pfad noch existiert
    if DirectoryExists( LastPath ) then
      ComboBoxExPath.Items[i] := LastPath
    else //wenn der Pfad nicht mehr existiert dann setze den Pfad auf Standart zurück
    begin
      ComboBoxExPath.Items[1] := DefaultSettings.DefaultUserSavePath;
      LastLoadPath := DefaultSettings.DefaultUserSavePath;
    end;

    LastUserStr := ini.Values[ SC_LASTUSER ];
    if ( not LastUserStr.Equals( SC_NOT_USED ) ) and ( not LastUserStr.Equals( '' ) )
    and ( IsLastUserAgainChecked ) then
      EditUser.Text := LastUserStr;

    CBMerkeUser.Checked := StrToBoolDef( ini.Values[ SC_ISLASTUSERCHK ], true );//Change: Seidel 2020-11-23

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
    if ini.IndexOf( SC_SEC ) = -1 then//Change: Seidel 2021-01-20
      ini.insert( 0 , SC_SEC );
    ini.Values[SC_FIRSTSTART] := BoolToStr( IsNewUserChecked, true );
    if not LastLoadPath.equals( SC_NOT_USED ) then
      ini.Values[SC_LASTKTPPATH] := LastLoadPath;
    ini.Values[SC_LASTUSER] := LastUser;//Change: Seidel 2020-11-23 speicherplatz zuletzt eingegebenen User
    ini.Values[SC_ISLASTUSERCHK] := BoolToStr( IsLastUserAgainChecked, true );//Change: Seidel 2020-11-23 Zustand der CheckBox
    CheckWriteAccessAndSave( ini );
  finally
    ini.Free;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-11-28
-------------------------------------------------------------------------------}
function TMainINI.CheckWriteAccessAndSave( const ini : TStringList; forCreate : Boolean = false ): Boolean;
begin
  Result := true;
  try
    SaveReadOnly( ini );//Change: Seidel 2021-02-04
  except
    Result := false;
    //wenn keine Schreibrechte vorhanden sind
    MessageCantWriteAccessAndSaveIni( forCreate );
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2021-02-04
-------------------------------------------------------------------------------}
procedure TMainINI.SaveReadOnly( const ini : TStringList );
begin
  if IsFileReadOnly( IniPath ) then
    FileSetAttr( IniPath, faNormal );

  ini.SaveToFile( IniPath );

  if not IsFileReadOnly( IniPath ) then
    FileSetAttr( IniPath, faReadOnly );
end;
end.

