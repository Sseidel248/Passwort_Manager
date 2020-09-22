unit Login_PWM;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  System.ImageList, Vcl.ImgList, Vcl.Buttons;

type
  TLogin = class(TForm)
    Image1: TImage;
    UsernameEdit: TEdit;
    UserMasterPWEdit: TEdit;
    AnmeldeBtn: TButton;
    ImageList1: TImageList;
    CBNewUser: TCheckBox;
    HideToggleBtn: TBitBtn;
    ImageList2: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure AnmeldeBtnClick(Sender: TObject);
    procedure UsernameEditChange(Sender: TObject);
    procedure UserMasterPWEditChange(Sender: TObject);
    procedure UsernameEditClick(Sender: TObject);
    procedure UsernameEditExit(Sender: TObject);
    procedure UserMasterPWEditClick(Sender: TObject);
    procedure UserMasterPWEditExit(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure CBNewUserClick(Sender: TObject);
    procedure UserMasterPWEditKeyPress(Sender: TObject; var Key: Char);
    procedure HideToggleBtnClick(Sender: TObject);
  private
    procedure TextChange( Edit : TEdit; Str : String);
    procedure TextStandart( Edit : TEdit; Str : String);
    procedure TextClick( Edit : TEdit; Str : String);

    function CheckPMKExist( PMPK_Str : string): Boolean;
    function CheckUserAndPW : Boolean;
    procedure EnableAnmeldeBtn;
    { Private-Deklarationen }
  public
    class function MD5String(const Input: String) : String;
    { Public-Deklarationen }
  end;

var
  Login : TLogin;

implementation

uses
  IdHashMessageDigest, IdHash, Main_PWM, Global_PWM, IniFiles, ZipForge;

{$R *.dfm}

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
    HideToggleBtn.Enabled := false;
  end
  else if Usertext.Equals( 'Benutzername eingeben...' ) or PwText.Equals( 'Master-Passwort eingeben...' ) then
  begin
    AnmeldeBtn.Enabled := false;
    HideToggleBtn.Enabled := false;
  end
  else
  begin
    AnmeldeBtn.Enabled := true;
    HideToggleBtn.Enabled := true;
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
  ZipForge := TZipForge.Create( nil );
  stream := TMemoryStream.Create;
  Sl := TStringList.Create;
  try
    with ZipForge do
    begin
      FileName := UserData.SavePath + UserData.PMPK_Name_MD5;
      OpenArchive( fmOpenRead );
      EncryptionMethod := caAES_256;
      Password := MD5String(PM_PW);
      if FindFirst( '*.ini', ArchiveItem, faAnyFile ) then
      begin
        stream.Clear;
        stream.Position := 0;
        ExtractToStream( archiveItem.FileName, stream );
        stream.Position := 0;
        Sl.LoadFromStream( stream );
        stream.Position := 0;
      end;
      Result := ( Sl.Values[SC_USER].Equals( UserData.User) ) and ( Sl.Values[SC_PW].Equals( UserData.PW_Str ) );
    end;
  finally
    ZipForge.Free;
    stream.Free;
    Sl.Free;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-20
-------------------------------------------------------------------------------}
procedure TLogin.CBNewUserClick(Sender: TObject);
begin
  if CBNewUser.Checked then
    AnmeldeBtn.Caption := 'Passwort-Safe öffnen und neuen Benutzer erzeugen'
  else
    AnmeldeBtn.Caption := 'Passwort-Safe öffnen';
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-20
-------------------------------------------------------------------------------}
function TLogin.CheckPMKExist( PMPK_Str : string ): Boolean;
var
SaveFile : string;
begin
  SaveFile := Concat( UserData.SavePath, PMPK_str , '.PMPK' );
  if FileExists( SaveFile ) then
    Result := true
  else
    Result := false;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-20
-------------------------------------------------------------------------------}
class function TLogin.MD5String( const Input: String ): String;
var
MD5: TIdHashMessageDigest5;
begin
  MD5 := TIdHashMessageDigest5.Create;
  try
    Result := Trim( MD5.HashStringAsHex(Input) );
  finally
    MD5.Free;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-20
-------------------------------------------------------------------------------}
procedure TLogin.AnmeldeBtnClick(Sender: TObject);
var
User, PwStr : String;
INI : TStrings;
begin
  Ini := TStringList.Create;
  try
    USer := Trim( UsernameEdit.Text );
    PwStr := UserMasterPWEdit.Text;
    UserData.PMPK_Name_MD5 := MD5String( User ) + '.PMPK';
    UserData.User := User;
    UserData.PW_Str := PwStr;

    if {CheckPMKExist( MD5String( User ) )} not CBNewUser.Checked then
    begin
      if ( CheckUserAndPW ) then
      begin
        ModalResult := mrOk; // ok = login erfolgreich
        ImageList1.GetIcon( 1, Image1.Picture.Icon );

        Login.Refresh;
        Sleep(500);
      end
      else
      begin
        ImageList1.GetIcon( 2, Image1.Picture.Icon );
        ShowMessage( 'Benutzername und Passwort stimmen nicht überein!' + sLineBreak + 'Versuchen Sie es erneut.');
        UsernameEdit.SelectAll;
      end;
    end
    else
    begin
      if MessageDlg( 'Benutzername existiert noch nicht, soll dieser angelegt werden?',
                  mtInformation,
                  [mbYes, mbNo], 0 ) = mrYes then
      begin
        ModalResult := mrRetry; //retry = neuer Benutzer
        UserData.PMPK_Name_MD5 := MD5String( User ) + '.PMPK';
        UserData.User := User;
        UserData.PW_Str := PwStr;
      end;
    end;
  finally
    Ini.Free;
  end;

end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-20
-------------------------------------------------------------------------------}
procedure TLogin.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  //Modalresult := mrClose;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-20
-------------------------------------------------------------------------------}
procedure TLogin.FormCreate(Sender: TObject);
begin
  UserData.SavePath := ExtractFileDir( ParamStr(0) ) + '\PM_DB\';
  UserData.FirstLoadPath := ExtractFileDir( ParamStr(0) ) + '\DB\';
  ImageList2.GetBitmap( 1, HideToggleBtn.Glyph );
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
begin
//  AnmeldeBtn.SetFocus;
  CBNewUser.SetFocus;
  ImageList1.GetIcon( 0, Image1.Picture.Icon );
end;


{------------------------------------------------------------------------------
Author: Seidel 2020-09-20
-------------------------------------------------------------------------------}
procedure TLogin.HideToggleBtnClick(Sender: TObject);
begin
  if UserMasterPWEdit.PasswordChar = '*' then
  begin
    HideToggleBtn.Glyph := nil;
    UserMasterPWEdit.PasswordChar := #0;
    ImageList2.GetBitmap( 1, HideToggleBtn.Glyph );
  end
  else
  begin
    HideToggleBtn.Glyph := nil;
    UserMasterPWEdit.PasswordChar := '*';
    ImageList2.GetBitmap( 0, HideToggleBtn.Glyph );
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-20
-------------------------------------------------------------------------------}
procedure TLogin.UserMasterPWEditChange(Sender: TObject);
begin
  TextChange( UserMasterPWEdit, 'Master-Passwort eingeben...' );
  EnableAnmeldeBtn;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-20
-------------------------------------------------------------------------------}
procedure TLogin.UserMasterPWEditClick(Sender: TObject);
begin
  TextClick( UserMasterPWEdit, 'Master-Passwort eingeben...' );
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-20
-------------------------------------------------------------------------------}
procedure TLogin.UserMasterPWEditExit(Sender: TObject);
begin
  TextStandart( UserMasterPWEdit, 'Master-Passwort eingeben...' );
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-20
-------------------------------------------------------------------------------}
procedure TLogin.UserMasterPWEditKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    AnmeldeBtnClick( Sender );
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-20
-------------------------------------------------------------------------------}
procedure TLogin.UsernameEditChange(Sender: TObject);
begin
  TextChange( UsernameEdit, 'Benutzername eingeben...' );
  EnableAnmeldeBtn;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-20
-------------------------------------------------------------------------------}
procedure TLogin.UsernameEditClick(Sender: TObject);
begin
  TextClick( UsernameEdit, 'Benutzername eingeben...' );
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-20
-------------------------------------------------------------------------------}
procedure TLogin.UsernameEditExit(Sender: TObject);
begin
  TextStandart( UsernameEdit, 'Benutzername eingeben...' );
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-20
-------------------------------------------------------------------------------}
procedure TLogin.TextChange( Edit : TEdit; Str : String);
var
EditText : String;
begin
  EditText := Edit.Text;
  if not EditText.Equals('') then
    Edit.Font.Color := clBlack
  else
    Edit.Font.Color := clScrollBar;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-20
-------------------------------------------------------------------------------}
procedure TLogin.TextStandart( Edit : TEdit; Str : String);
var
EditText : String;
begin
  EditText := Edit.Text;
  if EditText.Equals('') then
  begin
    Edit.Text := Str;
    Edit.Font.Color := clScrollBar;
  end
  else if EditText.Equals(Str) then
  begin
    Edit.Font.Color := clScrollBar;
  end
  else
  begin
    Edit.Font.Color := clBlack;
  end;

end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-20
-------------------------------------------------------------------------------}
procedure TLogin.TextClick( Edit : TEdit; Str : String);
var
EditText : String;
begin
  EditText := Edit.Text;
  if not EditText.Equals( Str ) then
    Edit.SelectAll
  else
    Edit.Clear;
end;

end.
