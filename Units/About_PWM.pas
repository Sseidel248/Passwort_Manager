unit About_PWM;

{******************************************************************************
Aboutdialog "KiiTree"
Author: Copyleft 2020 - 2021 Sebastian Seidel

Gibt Informationen �ber das Programm und den Entwickler preis
*******************************************************************************}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Imaging.pngimage,
  Vcl.ExtCtrls, GradientPanel;

type
  TAbout_Dlg = class(TForm)
    GradientPanelAboutDlg: TGradientPanel;
    Image1: TImage;
    LAboutTitel: TLabel;
    LVersion: TLabel;
    LInfo: TLabel;
    LOrtProg: TLabel;
    LCopyright: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure LOrtProgMouseEnter(Sender: TObject);
    procedure LOrtProgMouseLeave(Sender: TObject);
    procedure LOrtProgClick(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  About_Dlg: TAbout_Dlg;

implementation

uses
  ShellApi,
  Main_PWM,
  Global_PWM;

{$R *.dfm}

{------------------------------------------------------------------------------
Author: Seidel 2020-10-16
-------------------------------------------------------------------------------}
procedure TAbout_Dlg.FormCreate(Sender: TObject);
begin
  LVersion.Caption := 'Version: ' + GetMyVersion;// +  ' (beta)';
  LInfo.Caption := 'Dieses Programm ist ein Open Source Ein-Mann Projekt unter Verwendung von '
  +'ZipForge von Component Ace, TVirtualTreeView von JAM Software und InstanceCheck von Daniel Pauli.'
  +' Vorschl�ge f�r Verbesserungen oder Anmerkungen sind Herzlich willkommen.';
  LOrtProg.Caption := 'Besucht: https://github.com/Sseidel248/KiiTree f�r weitere Informtionen.';
  LCopyright.Caption := 'Copyright � 2020-2021 Sebastian Seidel';
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-17
-------------------------------------------------------------------------------}
procedure TAbout_Dlg.FormShow(Sender: TObject);
begin
  //Change 2020-10-17
  GradientPanelAboutDlg.Color := Main.GradientPanelMain.Color;
  GradientPanelAboutDlg.ColorTo := Main.GradientPanelMain.ColorTo;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-12-30
-------------------------------------------------------------------------------}
procedure TAbout_Dlg.LOrtProgClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', 'https://github.com/Sseidel248/KiiTree', nil, nil, SW_SHOWNORMAL);
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-12-30
-------------------------------------------------------------------------------}
procedure TAbout_Dlg.LOrtProgMouseEnter(Sender: TObject);
begin
  LOrtProg.Font.Color := clHotLight;
  LOrtProg.Font.Style := [fsUnderline];
  Screen.Cursor := crHandPoint;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-12-30
-------------------------------------------------------------------------------}
procedure TAbout_Dlg.LOrtProgMouseLeave(Sender: TObject);
begin
  LOrtProg.Font.Color := clBlack;
  LOrtProg.Font.Style := [];
  Screen.Cursor := crDefault;
end;

end.
