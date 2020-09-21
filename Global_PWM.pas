unit Global_PWM;

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

var
  UserData : TUserData;

implementation

end.
