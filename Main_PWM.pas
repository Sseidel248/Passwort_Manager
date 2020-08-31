unit Main_PWM;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.StdCtrls, Vcl.Buttons,
  Vcl.ToolWin, Vcl.ComCtrls, Vcl.ExtCtrls, VirtualTrees;

type
  TFonts = class
    FTitelSize : Integer;
    FTitelColor : TColor;
    FSchreibenSize : Integer;
    FSchreibenColor : TColor;
    FStandartColor : TColor;
  private
    procedure SetColor( aColor : TColor );
    procedure SetSize ( aSize : Integer );
  public
    property TitelSize : Integer read FTitelSize write SetSize;
    property TitelColor : TColor read FTitelColor write SetColor;
    property EditSize : Integer read FSchreibenSize write SetSize;
    property EditColor : TColor read FSchreibenColor write SetColor;
    property StandartColor : TColor read FStandartColor;
    constructor Create; virtual;
  end;

type
  TForm1 = class(TForm)
    MenuPanel: TPanel;
    Panel2: TPanel;
    LUser: TLabel;
    PasswortBtn: TButton;
    EinstellBtn: TButton;
    Button3: TButton;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    VST: TVirtualStringTree;
    SuchenEdit: TEdit;
    LBezeichnung: TLabel;
    LBenutzername: TLabel;
    LPasswort: TLabel;
    LInfo: TLabel;
    Memo1: TMemo;
    PasswortEdit: TEdit;
    SeePWBtn: TBitBtn;
    HidePWBtn: TBitBtn;
    Username: TEdit;
    Edit1: TEdit;
    LBenutzerDaten: TLabel;
    SaveDataBtn: TBitBtn;
    AddBtn: TBitBtn;
    DelBtn: TBitBtn;
    procedure PasswortBtnClick(Sender: TObject);
    procedure EinstellBtnClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    AFonts : TFonts;
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

//*****************************************************************************
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//Fonts-Klasse
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//*****************************************************************************
constructor TFonts.Create;
begin
  FTitelColor := clBlack;
  FTitelSize := 12;
  FSchreibenColor := clBlack;
  FSchreibenSize := 10;
  FStandartColor := clScrollBar;
end;

procedure TFonts.SetColor( aColor : TColor );
begin
  FSchreibenColor := aColor;
end;

procedure TFonts.SetSize(aSize: Integer);
begin
  FSchreibenSize := aSize;
end;
//*****************************************************************************
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//Fonts-Klasse Ende
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//*****************************************************************************

procedure TForm1.Button3Click(Sender: TObject);
begin
  PageControl1.ActivePage := TabSheet3;
end;

procedure TForm1.EinstellBtnClick(Sender: TObject);
begin
  PageControl1.ActivePage := TabSheet2;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
//TODO: Methode hinzufügen welche alle Fonts (Größe) dynamisch ändern lässt
end;

procedure TForm1.PasswortBtnClick(Sender: TObject);
begin
  PageControl1.ActivePage := TabSheet1;
end;

end.
