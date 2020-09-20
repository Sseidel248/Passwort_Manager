unit Login_PWM;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  System.ImageList, Vcl.ImgList;

type
  TLogin = class(TForm)
    Image1: TImage;
    UsernameEdit: TEdit;
    UserMasterPWEdit: TEdit;
    AnmeldeBtn: TButton;
    ImageList1: TImageList;
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
  private
    procedure TextChange( Edit : TEdit; Str : String);
    procedure TextStandart( Edit : TEdit; Str : String);
    procedure TextClick( Edit : TEdit; Str : String);
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Login: TLogin;

implementation

uses
  Main_PWM;

{$R *.dfm}

{------------------------------------------------------------------------------
Author: Seidel 2020-09-20
-------------------------------------------------------------------------------}
procedure TLogin.AnmeldeBtnClick(Sender: TObject);
var
User, PwStr : String;
begin
  USer := UsernameEdit.Text;
  PwStr := UserMasterPWEdit.Text;
  //INI aus der ZipDatei holen bzw erstmal eine Ini datei anlegen
  if ( User.Equals('test') ) and ( PwStr.Equals('1234') ) then
  begin
    ModalResult := mrOk;
    ImageList1.GetIcon( 1, Image1.Picture.Icon );
    Login.Refresh;
    Sleep(500);
  end
  else
  begin
    ImageList1.GetIcon( 2, Image1.Picture.Icon );
//    ShowMessage( 'Benutzername und Passwort stimmen nicht überein!' + sLineBreak + 'Versuchen Sie es erneut.');
    UsernameEdit.SelectAll;
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
  //
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
  AnmeldeBtn.SetFocus;
  ImageList1.GetIcon( 0, Image1.Picture.Icon );
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-20
-------------------------------------------------------------------------------}
procedure TLogin.UserMasterPWEditChange(Sender: TObject);
begin
  TextChange( UserMasterPWEdit, 'Master-Passwort eingeben...' );
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
procedure TLogin.UsernameEditChange(Sender: TObject);
begin
  TextChange( UsernameEdit, 'Benutzername eingeben...' );
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
