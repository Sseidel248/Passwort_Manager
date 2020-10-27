unit About_PWM;

{******************************************************************************
Aboutdialog "KiiTree"
Author: Sebastian Seidel

Gibt Informationen über das Programm und den Entwickler preis
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
    function GetVersion: string;
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  About_Dlg: TAbout_Dlg;

implementation

uses
  Main_PWM;

{$R *.dfm}

{------------------------------------------------------------------------------
Author: Seidel 2020-10-16
-------------------------------------------------------------------------------}
procedure TAbout_Dlg.FormCreate(Sender: TObject);
begin
  LVersion.Caption := 'Version: ' + GetVersion +  ' (beta)';
  LInfo.Caption := 'Dieses Programm ist ein Open Source Ein-Mann Projekt unter Verwendung von ZipForge von Component Ace. Vorschläge für Verbesserungen oder Anmerkungen sind Herzlich willkommen.';
  LOrtProg.Caption := 'Besucht: https://github.com/Sseidel248/KiiTree für weitere Informtionen.';
  LCopyright.Caption := 'Copyright © 2020 Sebastian Seidel. Alle Rechte sind vorbehalten.';
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
Author: Seidel 2020-10-17
von: www.swissdelphicenter.ch
-------------------------------------------------------------------------------}
function TAbout_Dlg.GetVersion: string;
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

end.
