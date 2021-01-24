unit MPW_Change_PWM;

{******************************************************************************
Masterpasswort Änderungsdialog "KiiTree"
Author: Copyleft 2020 - 2021 Sebastian Seidel

Dient dem Wechsel des Masterpasswortes
*******************************************************************************}

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes, System.UITypes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  GradientPanel,
  EditEx;

type
  TMasterPasswortChange = class(TForm)
    GradientPanelMPWChange: TGradientPanel;
    BChangeMasterPW: TButton;
    LStep1: TLabel;
    LStep2: TLabel;
    EOldMPW: TEditEx;
    ENewMPW: TEditEx;
    ENewMPW2: TEditEx;
    procedure EOldMPWChange(Sender: TObject);
    procedure ENewMPWChange(Sender: TObject);
    procedure ENewMPW2Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BChangeMasterPWClick(Sender: TObject);
    procedure EOldMPWKeyPress(Sender: TObject; var Key: Char);
    procedure ENewMPWKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    isStep1True : Boolean;
    isStep2True : Boolean;
    procedure CheckStep1;
    procedure CheckStep2;
    procedure ReadyToChange;
    procedure ColorChange( Edit : TEditEx; const AColor : TColor );
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  MasterPasswortChange: TMasterPasswortChange;

const
  colorNone = TColors.SysNone;

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
  if ( Edit1 ).Equals( Edit2 ) then  //Zusätzliche Sicherheitsüberprüfung
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
    ColorChange( EOldMPW, clRed );
  end
  else
  begin
    LStep1.Visible := false;
    ColorChange( EOldMPW, clGreen );
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
    ColorChange( ENewMPW, clRed );
    ColorChange( ENewMPW2, clRed );
  end
  else
  if EditText1.Equals('') and EditText2.Equals('') then//Change: Seidel 2021-01-23
  begin
    LStep2.Visible := false;
    ColorChange( ENewMPW, colorNone );
    ColorChange( ENewMPW2, colorNone );
  end
  else
  begin
    LStep2.Visible := false;
    ColorChange( ENewMPW, clGreen );
    ColorChange( ENewMPW2, clGreen );
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
Author: Seidel 2021-01-23
-------------------------------------------------------------------------------}
procedure TMasterPasswortChange.ColorChange( Edit : TEditEx; const AColor : TColor );
begin
  Edit.Bordercolor := AColor;
  Edit.FocusBorderColor := AColor;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-16
-------------------------------------------------------------------------------}
procedure TMasterPasswortChange.ENewMPW2Change(Sender: TObject);
begin
  CheckStep2;
  ENewMPW.Invalidate; //gegenseitiges Aktualisieren
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
Author: Seidel 2021-01-23
-------------------------------------------------------------------------------}
procedure TMasterPasswortChange.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  LStep1.Visible := false;
  ColorChange( EOldMPW, colorNone );

  LStep2.Visible := false;
  ColorChange( ENewMPW, colorNone );
  ColorChange( ENewMPW2, colorNone );
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-16
-------------------------------------------------------------------------------}
procedure TMasterPasswortChange.FormCreate(Sender: TObject);
begin
//
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
