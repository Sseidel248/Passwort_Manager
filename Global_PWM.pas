unit Global_PWM;

{******************************************************************************
Konstanten von "KiiTree"
Author: Sebastian Seidel

*******************************************************************************}

interface

type
  TUserData = record
    User : string;
    PW_Str : string;
    PMPK_Name_MD5 : String;
    SavePath : String;
    FirstLoadPath : string;
  end;

const
  SC_USER = 'User';
  SC_PW   = 'Password';
  SC_PMPK = 'PMPK-File';
  SC_EXT  = '.PMPK';

  SC_FAVORITEN = 'Favoriten';
  SC_ALLE      = 'Alle';

  SC_BEZEICHNUNG = 'Bezeichnung eingeben...';
  SC_BENUTZER    = 'Benutzername eingeben...';
  SC_PASSWORT    = 'Passwort eingeben...';
  SC_URL         = 'Internetseite eingeben...';
  SC_NOTIZ       = 'Ihre Notiz';
  SC_MASTER_PW   = 'Master-Passwort eingeben...';

var
  UserData : TUserData;

implementation

end.
