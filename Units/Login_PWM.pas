unit Login_PWM;

{******************************************************************************
Login Dialog von "KiiTree"
Author: Copyleft 2020 - 2021 Sebastian Seidel

*******************************************************************************}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  System.ImageList, Vcl.ImgList, Vcl.Buttons, GradientPanel, System.UITypes,
  Edit4User, U_USB, Vcl.VirtualImageList, Vcl.BaseImageCollection,
  Vcl.ImageCollection, EditEx, Vcl.ComCtrls, MyGlassButton;

type
  TLoginState = Set of (
    lsWrongPW              //wird gesetzt wenn das Passwort falsch ist
    );

type
  TLogin = class(TForm)
    Image1: TImage;
    AnmeldeBtn: TButton;
    CBNewUser: TCheckBox;
    ImageList2: TImageList;
    ImageList3: TImageList;
    Label1: TLabel;
    UsernameEdit: TEdit4User;
    GradientPanel2: TGradientPanel;
    USBInput: TComponentUSB;
    CBMerkeUser: TCheckBox;
    Label2: TLabel;
    AnmeldeTimer: TTimer;
    ImageCollection1: TImageCollection;
    VirtualImageList1: TVirtualImageList;
    UserMasterPWEdit: TEditEx;
    ESavePathForKTPs: TComboBoxEx;
    VirtualImageList2: TVirtualImageList;
    BGetKTPSavePath: TGlassButton;//Change: Seidel 2021-01-28
    SBToogleHide: TGlassButton;//Change: Seidel 2021-01-28
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure AnmeldeBtnClick(Sender: TObject);
    procedure UsernameEditChange(Sender: TObject);
    procedure UserMasterPWEditChange(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure CBNewUserClick(Sender: TObject);
    procedure UserMasterPWEditKeyPress(Sender: TObject; var Key: Char);
    procedure UsernameEditKeyPress(Sender: TObject; var Key: Char);
    procedure SBToogleHideClick(Sender: TObject);
    procedure BGetKTPSavePathClick(Sender: TObject);
    procedure USBInputUSBGetDriveLetter(Sender: TObject;
      const DrivePath: string);
    procedure USBInputUSBRemove(Sender: TObject);
    procedure CBMerkeUserClick(Sender: TObject);
    procedure AnmeldeTimerTimer(Sender: TObject);
    procedure FormAfterMonitorDpiChanged(Sender: TObject; OldDPI,
      NewDPI: Integer);
    procedure ESavePathForKTPsChange(Sender: TObject);
    procedure ESavePathForKTPsEndEdit(Sender: TObject);
    procedure ESavePathForKTPsBeginEdit(Sender: TObject);
  private
//    LoginStates : TLoginStates;                                             //erstmal nicht benutzt
//    property LoginState : TLoginStates read LoginStates write LoginStates;  //erstmal nicht benutzt
    ImageIndex : Integer;//Change: Seidel 2020-12-29
    AnmeldeSek : Integer;
    FLoginState : TLoginState;
    procedure CheckKTPExist( SaveFile : string ) ;                   //erstmal nicht benutzt
    function CheckUserAndPW : Boolean;
    procedure EnableAnmeldeBtn;
    function CheckKTPExistPlus( SaveFile : String ) : Boolean;
    procedure DoChangeState( Enter : TLoginState; Leave : TLoginState = [] );
    procedure InitSavePathes;
//    function Check4FirstStart: Boolean;


//    procedure TextChange( Edit : TEdit; Str : String );
//    procedure TextStandart( Edit : TEdit; Str : String );
//    procedure TextClick( Edit : TEdit; Str : String );
    { Private-Deklarationen }
  public
//    class procedure TextChange( Edit : TEdit; Str : String );              //erstmal nicht benutzt
//    class procedure TextStandart( Edit : TEdit; Str : String );            //erstmal nicht benutzt
//    class procedure TextClick( Edit : TEdit; Str : String );               //erstmal nicht benutzt
//    class function MD5String( const Input: String ) : String;              //erstmal nicht benutzt
//    class function SHA256String( const Input : String ) : String;          //erstmal nicht benutzt
//    procedure ChangeLoginState( Enter : TLoginStates; Leave : TLoginStates = []);  //erstmal nicht benutzt
    { Public-Deklarationen }
  end;

var
  Login : TLogin;


implementation

uses
  IdHashMessageDigest,
  IdHash,
  Main_PWM,
  Global_PWM,
  IniFiles,
  Messages_PWM,
  System.Zip,
  ZipForge,
  Hash_Functions;

{$R *.dfm}

{------------------------------------------------------------------------------
Author: Seidel 2020-10-17
-------------------------------------------------------------------------------}
//function TLogin.Check4FirstStart: Boolean;
//var
//ini : TStringList;
//iniName : String;
//begin
//  ini := TStringList.Create;
//  try
//    //nur zum überprüfen falls es doch gelöscht wurde
//    if not FileExists( MainIni.IniPath ) then
//    begin
//      MainIni.CreateIfNotExist;
//    end;
//    ini.LoadFromFile( MainIni.IniPath );
//    Result := StrToBoolDef( ini.Values[ SC_FIRSTSTART ], true );
//  finally
//    ini.Free;
//  end;
//end;

{------------------------------------------------------------------------------
Author: Seidel 2020-11-24
-------------------------------------------------------------------------------}
procedure TLogin.DoChangeState( Enter : TLoginState; Leave : TLoginState = [] );
begin
  FLoginState := FLoginState + Enter - Leave;
end;

{------------------------------------------------------------------------------
Author: Seidel 2021-01-26
-------------------------------------------------------------------------------}
procedure TLogin.InitSavePathes;
begin
  ESavePathForKTPs.Items.Add( SC_LOKAL );
  ESavePathForKTPs.Items.Add( DefaultSettings.DefaultUserSavePath );
  if not MainIni.ServerSavePath.Equals( '' ) then
  begin
    ESavePathForKTPs.Items.Add( SC_SERVER );
    ESavePathForKTPs.Items.Add( MainIni.ServerSavePath );
  end;
  ESavePathForKTPs.Items.Add( SC_LASTPATHUSED );
  ESavePathForKTPs.Items.Add( MainIni.LastPathUsed );

  ESavePathForKTPs.ItemIndex := Mainini.GetUserPathIndex;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-22
-------------------------------------------------------------------------------}
function TLogin.CheckKTPExistPlus( SaveFile : String ) : Boolean;

  function IsFileValid( SaveFile : String) : Boolean;//Change: Seidel 2020-11-22 kontrolle von 0 Byte Dateien
  var
  FileStream: TFileStream;
  ZipFile : TZipFile;
  begin
    //teste 0 Byte Dateien
    FileStream := TFileStream.Create( SaveFile, fmOpenRead or fmShareDenyNone );
    try
      try
        if FileStream.Size <= 0 then
          Result := false
        else
          Result := true;
      except
        Result := false;
      end;
    finally
      FileStream.Free;
    end;
    //teste ob es ein Archiv ist
    ZipFile := TZipFile.Create;
    try
      if not ZipFile.IsValid( SaveFile ) then
        Result := false;
    finally
      ZipFile.Free;
    end;
  end;

begin
  Result := false;
  if FileExists( SaveFile ) then
  begin
    if IsFileValid( SaveFile ) then
      Result := true
    else
    begin
      //TODO: Datei statt Benutzername wählen können
      MessageFileCurrpt();
    end;
  end
  else
  begin
    MessageFileCurrpt( false );
    Result := false;
    BGetKTPSavePath.SetFocus;
  end;
end;


{------------------------------------------------------------------------------
Author: Seidel 2020-09-20
-------------------------------------------------------------------------------}
procedure TLogin.EnableAnmeldeBtn;
var
Usertext, PwText : string;
begin
  Usertext := UsernameEdit.Text;
  PwText := UserMasterPWEdit.Text;
  if Usertext.Equals( '' ) or PwText.Equals( '' ) then
  begin
    AnmeldeBtn.Enabled := false;
    SBToogleHide.Visible := false;
  end
  else
  if ( not UsernameEdit.UserExist ) and ( CBNewUser.Checked ) then
  begin
    AnmeldeBtn.Enabled := true;
    SBToogleHide.Visible := true;
  end
  else
  if UsernameEdit.UserExist and ( CBNewUser.Checked ) then
  begin
    AnmeldeBtn.Enabled := false;
    SBToogleHide.Visible := false;
  end
  else
  if UsernameEdit.UserExist and ( not CBNewUser.Checked ) then
  begin
    AnmeldeBtn.Enabled := true;
    SBToogleHide.Visible := true;
  end
  else
  begin
    AnmeldeBtn.Enabled := true;
    SBToogleHide.Visible := true;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-20
-------------------------------------------------------------------------------}
function TLogin.CheckUserAndPW : Boolean;
var
ZipForge : TZipForge;
ArchiveItem : TZFArchiveItem;
stream : TMemoryStream;
Sl : TStringlist;
begin
  {$IFDEF TESTLOGIN}
    Result := UserData.User.Equals( UserData.PW_Str );
    Exit;
  {$ENDIF}
  Result := false;
  ZipForge := TZipForge.Create( nil );
  stream := TMemoryStream.Create;
  Sl := TStringList.Create;
  try
    with ZipForge do
    begin
      FileName := GetActualSaveFile( UserData.KTP_Name_MD5 );
      OpenArchive( fmOpenRead );
      EncryptionMethod := caAES_256;
      Password := AnsiString( GetCryptStr( PM_PW, UserData.User, UserData.PW_Str ) );
//      Password := SHA256String( PM_PW );
//      Password := MD5String(PM_PW);  //Change 2020.09.28
      if FindFirst( '*.ini', ArchiveItem, faAnyFile ) then
      begin
        if IsFilePasswordValid( archiveItem.FileName , Password ) then//Change 2020-10-10
        begin
          stream.Clear;
          stream.Position := 0;
          ExtractToStream( archiveItem.FileName, stream );
          stream.Position := 0;
          Sl.LoadFromStream( stream );
          stream.Position := 0;
          Result := ( Sl.Values[SC_USER].Equals( UserData.User) )
                    and ( Sl.Values[SC_PW].Equals( UserData.PW_Str )
                    and ( Sl.Values[SC_KTP].Equals( UserData.KTP_Name_MD5 ) ) );
        end;
      end;
      CloseArchive;
    end;
  finally
    ZipForge.Free;
    stream.Free;
    Sl.Free;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2021-01-26
-------------------------------------------------------------------------------}
procedure TLogin.ESavePathForKTPsBeginEdit(Sender: TObject);
begin
  ESavePathForKTPs.ItemIndex := MainIni.GetUserPathIndex;
end;

{------------------------------------------------------------------------------
Author: Seidel 2021-01-27
-------------------------------------------------------------------------------}
procedure TLogin.ESavePathForKTPsChange(Sender: TObject);
var
s : String;
begin
  if ESavePathForKTPs.Items.Count = 0 then
    Exit;

  case ESavePathForKTPs.ItemIndex of//Change: Seidel 2021-02-11
    0: ESavePathForKTPs.ItemIndex := 1;
    2: ESavePathForKTPs.ItemIndex := 3;
    4: ESavePathForKTPs.ItemIndex := 5;
  end;

  s := ESavePathForKTPs.Text;
  if not DirectoryExists( s ) then
  begin
    AnmeldeBtn.Enabled := false;
    if s.Equals( '' ) then
    begin
      ESavePathForKTPs.Hint := 'Pfad darf nicht leer sein!';
    end
    else
    begin
      ESavePathForKTPs.Hint := '"' + s + '" existiert nicht!' + sLineBreak + 'Bitte wählen Sie einen Anderen.';
    end;
    ESavePathForKTPs.Font.Color := clRed;
    Exit;
  end
  else
  begin
    AnmeldeBtn.Enabled := true;
    ESavePathForKTPs.Hint := s;
    ESavePathForKTPs.Font.Color := clWindowText;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2021-01-26
-------------------------------------------------------------------------------}
procedure TLogin.ESavePathForKTPsEndEdit(Sender: TObject);
var
text : String;
  I: Integer;
begin
  text := ESavePathForKTPs.Text;
  if not DirectoryExists( Text ) then
  begin
    ESavePathForKTPs.ItemIndex := 1;
    Exit;
  end;

  i := MainIni.GetUserPathIndex;

  ESavePathForKTPs.Items.Delete( I );
  ESavePathForKTPs.Items.Insert( I, text );

  //fügt den manuell veränderten Pfad in die MainIni hinzu, dieser wird dann kontrolliert
  MainIni.LastPathUsed := ESavePathForKTPs.Items[I];
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-11-24
-------------------------------------------------------------------------------}
procedure TLogin.AnmeldeTimerTimer(Sender: TObject);
begin
  dec( AnmeldeSek );
  UserMasterPWEdit.Text := 'Passwort falsch, ' + IntToStr( AnmeldeSek ) + ' Sek. warten';

  if AnmeldeSek = 0 then
  begin
    UserMasterPWEdit.Text := '';
    UserMasterPWEdit.Enabled := true;
    UserMasterPWEdit.PasswordChar := '*';

    AnmeldeBtn.Enabled := true;
    SBToogleHide.Enabled := true;

    DoChangeState( [], [lsWrongPW] );
    AnmeldeTimer.Enabled := false;
    AnmeldeSek := 5;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-07
-------------------------------------------------------------------------------}
procedure TLogin.BGetKTPSavePathClick(Sender: TObject);
var
OpenDialog : TFileOpenDialog;
i : Integer;
begin
  OpenDialog := TFileOpenDialog.Create( nil );
  try
    OpenDialog.Options := [fdoPathMustExist, fdoPickFolders];
    OpenDialog.Title := 'Wählen Sie den Ordner in dem Ihr KiiTree gespeichert wurde';
    if OpenDialog.Execute then //Pfad wird NUR gesetzt wenn ein Ordner erfolgreich gewählt wurde
    begin
      MainIni.LastPathUsed := OpenDialog.FileName + '\';
      i := MainIni.GetUserPathIndex;
      ESavePathForKTPs.items[I] := OpenDialog.FileName + '\';
      ESavePathForKTPs.ItemIndex := I;
    end
  finally
    OpenDialog.Free;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-11-23
-------------------------------------------------------------------------------}
procedure TLogin.CBMerkeUserClick(Sender: TObject);
begin
  MainIni.IsLastUserAgainChecked := CBMerkeUser.Checked;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-20
-------------------------------------------------------------------------------}
procedure TLogin.CBNewUserClick(Sender: TObject);
begin
  UsernameEdit.Clear;

  if CBNewUser.Checked then
    AnmeldeBtn.Caption := 'Passwort-Safe öffnen und neuen Benutzer erzeugen'
  else
    AnmeldeBtn.Caption := 'Passwort-Safe öffnen';

  EnableAnmeldeBtn;
  UsernameEdit.Required := CBNewUser.Checked;
  MainIni.IsNewUserChecked := CBNewUser.Checked;
  UsernameEdit.Invalidate;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-20
-------------------------------------------------------------------------------}
procedure TLogin.CheckKTPExist( SaveFile : string );
begin
  if FileExists( SaveFile ) then
  begin
    UsernameEdit.UserExist := true;
    UsernameEdit.Hint := 'Kein passender KiiTree in dem Verzeichnis gefunden!';
  end
  else
    UsernameEdit.UserExist := false;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-20 !!Modalresult schließt ein Modal geöffnetes Formular
-------------------------------------------------------------------------------}
procedure TLogin.AnmeldeBtnClick(Sender: TObject);

  procedure TimerWrongPWOn;
  begin
    if AnmeldeSek = 5 then
    begin
      AnmeldeTimer.Enabled := true;

      UserMasterPWEdit.Text := 'Passwort falsch, ' + IntToStr( AnmeldeSek ) + ' Sek. warten';
      UserMasterPWEdit.Enabled := false;

      UserMasterPWEdit.PasswordChar := #0;
      AnmeldeBtn.Enabled := false;
      SBToogleHide.Enabled := false;
      DoChangeState( [lsWrongPW] );
    end;
  end;

var
User, PwStr : String;
SaveStr : String;
begin
  USer := Trim( UsernameEdit.Text );
  PwStr := UserMasterPWEdit.Text;
  //initialisierung des Benutzers mit den Defaultwerten
  UserData.InitUserData( User, PwStr, GetMD5String( User ) + SC_EXT );
//  UserData.KTP_Name_MD5 := GetMD5String( User ) + SC_EXT;
//  UserData.User := User;
//  UserData.PW_Str := PwStr;
  SaveStr := GetActualSaveFile( UserData.KTP_Name_MD5 );

  //Imagelist 0 = start; 1 = OK; 2 = fail
  try
    if {CheckPMKExist( MD5String( User ) )} not CBNewUser.Checked then  //bestehenden Benutzer wählen
    begin
      {$IFNDEF TESTLOGIN}
      if not CheckKTPExistPlus( SaveStr ) then
        Exit;
      {$ENDIF}

      if FileExists( SaveStr ) then  //prüfen ob der Benutzer existiert
      begin
        if ( CheckUserAndPW ) then // und eingabe stimmt
        begin
          ModalResult := mrOk; // ok = 1 login erfolgreich
          VirtualImageList1.GetIcon( 1, Image1.Picture.Icon );
          ImageIndex := 1;
          {$IFNDEF TESTLOGIN}
            Login.Refresh;
            Sleep(500);
          {$ENDIF}
        end
        else   //und eingabe stimmt nicht
        begin
          VirtualImageList1.GetIcon( 2, Image1.Picture.Icon );
          ImageIndex := 2;
          {$IFNDEF TESTLOGIN}
//            ShowMessage( 'Benutzername und Passwort stimmen nicht überein!' + sLineBreak + 'Versuchen Sie es erneut.');
//            UsernameEdit.SelectAll;
            Login.Refresh;
          {$ELSE}
          ModalResult := mrClose;  // = 8
          {$ENDIF}
          TimerWrongPWOn;
        end;
      end
      else //Benutzer existiert nicht
      begin
        {$IFNDEF TESTLOGIN}
        if MessageUserNotExist = mrYes then
        begin
          VirtualImageList1.GetIcon( 1, Image1.Picture.Icon );
          ImageIndex := 1;
          ModalResult := mrRetry; //retry = 4 neuer Benutzer
//          UserData.KTP_Name_MD5 := GetMD5String( User ) + SC_EXT;
//          UserData.User := User;
//          UserData.PW_Str := PwStr;

          Login.Refresh;
          Sleep(500);
        end;
        {$ELSE}
          ModalResult := mrRetry; // 4
        {$ENDIF}
      end;
    end
    else //neuer Benutzer soll erstellt werden
    begin
      //es wurde einer neuer Benutzer erstellt, deshalb beim nächsten Start "Neuer Benutzer" Checkbox = false
      MainIni.IsNewUserChecked := false;
      VirtualImageList1.GetIcon( 1, Image1.Picture.Icon );
      ImageIndex := 1;
      {$IFNDEF TESTLOGIN}
//        UserData.KTP_Name_MD5 := GetMD5String( User ) + SC_EXT;
//        UserData.User := User;
//        UserData.PW_Str := PwStr;
        Login.Refresh;
        Sleep(500);
      {$ENDIF}
      ModalResult := mrRetry; //retry = 4 neuer Benutzer
    end;
  finally
    {$IFNDEF TESTLOGIN}
    MainIni.SaveSetting;
    {$ENDIF}
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-12-29
-------------------------------------------------------------------------------}
procedure TLogin.FormAfterMonitorDpiChanged(Sender: TObject; OldDPI,
  NewDPI: Integer);
begin
  VirtualImageList1.GetIcon( ImageIndex, Image1.Picture.Icon );
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-20
-------------------------------------------------------------------------------}
procedure TLogin.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // abschalten der USB Erkennung
  USBInput.Required := false;
  MainIni.SaveSetting;

end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-20
-------------------------------------------------------------------------------}
procedure TLogin.FormCreate(Sender: TObject);
begin
//  ImageList2.GetBitmap( 0, SBToogleHide.Glyph );
//  SBToogleHide.Flat := true;
  ESavePathForKTPs.Hint := 'Speicherverzeichnis von KiiTree';
  AnmeldeSek := 5;
  ESavePathForKTPs.Items.Clear;
  ESavePathForKTPs.ItemIndex := 1;
  ESavePathForKTPs.Hint := 'Der angebene Pfad existiert nicht.';
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-20
-------------------------------------------------------------------------------}
procedure TLogin.FormHide(Sender: TObject);
begin
//  Sleep(500);
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-20
-------------------------------------------------------------------------------}
procedure TLogin.FormShow(Sender: TObject);
var
EditText : String;
begin
  InitSavePathes;

  VirtualImageList1.GetIcon( 0, Image1.Picture.Icon );
  ImageIndex := 0;

  USBInput.Required := true;

  //Überprüfe ob der Speicherordner vom installieren vorhanden ist ( Standartverzeichnis )
  if not DirectoryExists( DefaultSettings.DefaultUserSavePath ) then
    ForceDirectories( DefaultSettings.DefaultUserSavePath );

  {$IFNDEF TESTLOGIN}
  //nur zur Sicherheit
  if not MainIni.CreateIfNotExist then
    Application.Terminate
  else
    MainIni.LoadSetting( CBNewUser, CBMerkeUser, ESavePathForKTPs, UsernameEdit );

  {$ENDIF}
  EditText := UsernameEdit.Text;
  if CBMerkeUser.Checked and not EditText.Equals( '' ) then
    UserMasterPWEdit.SetFocus
  else
  begin
    UsernameEdit.SetFocus;
    UsernameEdit.Clear;
  end;
//  ImageList1.GetIcon( 0, Image1.Picture.Icon );
//  PersonalFolder := GetSpecialFolder( Handle, IC_GET_PERSONAL_FOLDER ) + 'Documents\KiiTree\';
//  ESavePathForKTPs.Text := PersonalFolder;
//  UserData.PersonalUserSavePath := PersonalFolder;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-30
-------------------------------------------------------------------------------}
procedure TLogin.SBToogleHideClick(Sender: TObject);
begin
  if UserMasterPWEdit.PasswordChar = '*' then
  begin
//    SBToogleHide.Glyph := nil;
    UserMasterPWEdit.PasswordChar := #0;
//    ImageList2.GetBitmap( 1, SBToogleHide.Glyph );
    SBToogleHide.ImageIdx := 2;
    SBToogleHide.Hint := 'Masterpaswort verstecken';//Change: Seidel 2021-03-19
  end
  else
  begin
//    SBToogleHide.Glyph := nil;
    UserMasterPWEdit.PasswordChar := '*';
//    ImageList2.GetBitmap( 0, SBToogleHide.Glyph );
    SBToogleHide.ImageIdx := 1;
    SBToogleHide.Hint := 'Masterpaswort zeigen';//Change: Seidel 2021-03-19
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-23
-------------------------------------------------------------------------------}
procedure TLogin.USBInputUSBGetDriveLetter(Sender: TObject;
  const DrivePath: string);
begin
  if MessageFindDrive = mrYes then
  begin
    MainIni.LastPathUsed := DrivePath;
    ESavePathForKTPs.Text := DrivePath;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-23
-------------------------------------------------------------------------------}
procedure TLogin.USBInputUSBRemove(Sender: TObject);
begin
  MainIni.LastPathUsed := DefaultSettings.DefaultUserSavePath;
  ESavePathForKTPs.Text := DefaultSettings.DefaultUserSavePath;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-20
-------------------------------------------------------------------------------}
procedure TLogin.UserMasterPWEditChange(Sender: TObject);
begin
  if not ( lsWrongPW in FLoginState ) then//Change: Seidel 2020-11-24
    EnableAnmeldeBtn;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-20
-------------------------------------------------------------------------------}
procedure TLogin.UserMasterPWEditKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    if AnmeldeBtn.Enabled then//Change: Seidel 2020-12-29
      AnmeldeBtnClick( Sender );
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-20
-------------------------------------------------------------------------------}
procedure TLogin.UsernameEditChange(Sender: TObject);
var
Username :String;
Path : String;
//NameWithPath : String;
UserKTP : String;
begin

    Username := GetMD5String( UsernameEdit.Text ) + SC_EXT;
    MainIni.LastUser := UsernameEdit.Text;//Change: Seidel 2020-11-23
  //speicherpfad innerhalb des Programms
//  NameWithPath := Concat( UserData.AppSavePath, Username );
  //Speicherpfad im "Eigene Dateien" Ordner
  //TODO: MainIni.LastLoadPath anpassen
    Path := GetActualSavePath;
    UserKTP := Concat( Path, Username );
//  if CheckKTPExist( NameWithPath ) then
//    UsernameEdit.UserExist := true
//  else
  if CBNewUser.Checked then
  begin
    CheckKTPExist( UserKTP );
  end;
  EnableAnmeldeBtn;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-20
-------------------------------------------------------------------------------}
procedure TLogin.UsernameEditKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    UserMasterPWEdit.SetFocus;
    UserMasterPWEdit.SelectAll;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-20
-------------------------------------------------------------------------------}
//procedure TLogin.TextChange( Edit : TEdit; Str : String);
//var
//EditText : String;
//begin
//  EditText := Edit.Text;
//  if not EditText.Equals('') then
//    Edit.Font.Color := clBlack
//  else
//    Edit.Font.Color := clMedGray;
//end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-20
-------------------------------------------------------------------------------}
//procedure TLogin.TextStandart( Edit : TEdit; Str : String);
//var
//EditText : String;
//begin
//  EditText := Edit.Text;
//  if EditText.Equals('') then
//  begin
//    Edit.Text := Str;
//    Edit.Font.Color := clMedGray;
//  end
//  else if EditText.Equals(Str) then
//  begin
//    Edit.Font.Color := clMedGray;
//  end
//  else
//  begin
//    Edit.Font.Color := clBlack;
//  end;
//
//end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-20
-------------------------------------------------------------------------------}
//procedure TLogin.TextClick( Edit : TEdit; Str : String);
//var
//EditText : String;
//begin
//  EditText := Edit.Text;
//  if not EditText.Equals( Str ) then
//    Edit.SelectAll
//  else
//    Edit.Clear;
//end;

end.

