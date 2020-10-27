unit MPW_Change_PWM;

{******************************************************************************
Masterpasswort Änderungsdialog "KiiTree"
Author: Sebastian Seidel

Dient dem Wechsel des Masterpasswortes
*******************************************************************************}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  GradientPanel, Edit4User, EditWithBorder;

type
  TMasterPasswortChange = class(TForm)
    GradientPanelMPWChange: TGradientPanel;
    BChangeMasterPW: TButton;
    EOldMPW: TEditWithBorder;
    ENewMPW: TEditWithBorder;
    ENewMPW2: TEditWithBorder;
    LStep1: TLabel;
    LStep2: TLabel;
    procedure EOldMPWChange(Sender: TObject);
    procedure ENewMPWChange(Sender: TObject);
    procedure ENewMPW2Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BChangeMasterPWClick(Sender: TObject);
    procedure EOldMPWKeyPress(Sender: TObject; var Key: Char);
    procedure ENewMPWKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
  private
    isStep1True : Boolean;
    isStep2True : Boolean;
    procedure CheckStep1;
    procedure CheckStep2;
    procedure ReadyToChange;
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  MasterPasswortChange: TMasterPasswortChange;

implementation

uses
  Global_PWM, ZipForge, Hash_Functions, Main_PWM;

{$R *.dfm}

{------------------------------------------------------------------------------
Author: Seidel 2020-10-17
-------------------------------------------------------------------------------}
procedure TMasterPasswortChange.BChangeMasterPWClick(Sender: TObject);
var
NewPW : String;
Edit1, Edit2 : String;
begin
  Edit1 := ENewMPW.Text;
  Edit2 := ENewMPW2.Text;
  if ( Edit1 ).Equals( Edit2 ) then  //sicherheitsüberprüfung
  begin
    NewPW := ENewMPW.Text;
    UserData.PW_Str := NewPW;
    ModalResult := mrOk;  //!!Modalresult schließt den Dialog!
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-16
-------------------------------------------------------------------------------}
procedure TMasterPasswortChange.CheckStep1;
var
EditText : String;
begin
  EditText := EOldMPW.Text;
  isStep1True := EditText.Equals( UserData.PW_Str );
  if not isStep1True then
  begin
    LStep1.Visible := true;
    EOldMPW.Required := true;
  end
  else
  begin
    LStep1.Visible := false;
    EOldMPW.Required := false;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-16
-------------------------------------------------------------------------------}
procedure TMasterPasswortChange.CheckStep2;
var
EditText1,
EditText2 : String;
begin
  EditText1 := ENewMPW.Text;
  EditText2 := ENewMPW2.Text;
  isStep2True := EditText1.Equals( EditText2 );
  if not isStep2True then
  begin
    LStep2.Visible := true;
    ENewMPW.Required := true;
    ENewMPW2.Required := true;
  end
  else
  begin
    LStep2.Visible := false;
    ENewMPW.Required := false;
    ENewMPW2.Required := false;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-16
-------------------------------------------------------------------------------}
procedure TMasterPasswortChange.ReadyToChange;
begin
  BChangeMasterPW.Enabled := isStep1True and isStep2True;
end;


{------------------------------------------------------------------------------
Author: Seidel 2020-10-16
-------------------------------------------------------------------------------}
procedure TMasterPasswortChange.ENewMPW2Change(Sender: TObject);
begin
  CheckStep2;
  ENewMPW.Invalidate;
  ReadyToChange;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-16
-------------------------------------------------------------------------------}
procedure TMasterPasswortChange.ENewMPWChange(Sender: TObject);
begin
  CheckStep2;
  ENewMPW2.Invalidate; //gegenseitiges Aktualisieren
  ReadyToChange;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-17
-------------------------------------------------------------------------------}
procedure TMasterPasswortChange.ENewMPWKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    ENewMPW2.SetFocus;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-16
-------------------------------------------------------------------------------}
procedure TMasterPasswortChange.EOldMPWChange(Sender: TObject);
begin
  CheckStep1;
  EOldMPW.Invalidate; //gegenseitiges Aktualisieren
  ReadyToChange;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-17
-------------------------------------------------------------------------------}
procedure TMasterPasswortChange.EOldMPWKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    ENewMPW.SetFocus;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-16
-------------------------------------------------------------------------------}
procedure TMasterPasswortChange.FormCreate(Sender: TObject);
begin
  EOldMPW.Hint := 'Ihr altes Masterpasswort';
  ENewMPW.Hint := 'Ihr neues Masterpasswort';
  ENewMPW2.Hint := 'Zweiteingabe des neuen Masterpasswortes';

  EOldMPW.ForEmptyText := false;
  ENewMPW.ForEmptyText := false;
  ENewMPW2.ForEmptyText := false;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-17
-------------------------------------------------------------------------------}
procedure TMasterPasswortChange.FormShow(Sender: TObject);
begin
  //Change 2020-10-17
  GradientPanelMPWChange.Color := Main.GradientPanelMain.Color;
  GradientPanelMPWChange.ColorTo := Main.GradientPanelMain.ColorTo;
end;

end.
