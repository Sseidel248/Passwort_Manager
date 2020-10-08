unit Global_PWM;

{******************************************************************************
Konstanten von "KiiTree"
Author: Sebastian Seidel

*******************************************************************************}

interface

uses
  ActiveX, ShellAPI, ShlObj, vcl.Dialogs, WinAPI.Windows;

type
  TUserData = record
    User : string;
    PW_Str : string;
    KTP_Name_MD5 : String;
    AppSavePath : String;            // Speicherpfad der Exe
    PersonalUserSavePath : String;   // C:\Users\<Name des Benutzers>\KiiTree\
    FirstLoadPath : string;
  end;

const
  SC_USER = 'User';
  SC_PW   = 'Password';
  SC_KTP = 'KTP-File';
  SC_EXT  = '.KTP';

  SC_FAVORITEN = 'Favoriten';
  SC_ALLE      = 'Alle';

  SC_BEZEICHNUNG = 'Bezeichnung eingeben...';
  SC_BENUTZER    = 'Benutzername eingeben...';
  SC_PASSWORT    = 'Passwort eingeben...';
  SC_URL         = 'Internetseite eingeben...';
  SC_NOTIZ       = 'Ihre Notiz';
  SC_MASTER_PW   = 'Master-Passwort eingeben...';

  IC_GET_PERSONAL_FOLDER = CSIDL_PERSONAL;

  //mit CSIDL_PERSONAL Eigene Dateien Ordner
  //z.B. C:\Users\<Benutzername_PC>\
function GetSpecialFolder(hWindow: HWND; Folder: Integer): String;

var
  UserData : TUserData;

implementation

uses
  SysUtils;

function GetSpecialFolder(hWindow: HWND; Folder: Integer): String;
var
  pMalloc: IMalloc;
  pidl: PItemIDList;
  Path: PChar;
begin
  // get IMalloc interface pointer
  if (SHGetMalloc(pMalloc) <> S_OK) then
  begin
    MessageBox(hWindow, 'Couldn''t get pointer to IMalloc interface.',
               'SHGetMalloc(pMalloc)', 16);
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

end.
