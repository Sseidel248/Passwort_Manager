unit Main_PWM;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.StdCtrls, Vcl.Buttons,
  Vcl.ToolWin, Vcl.ComCtrls, Vcl.ExtCtrls, VirtualTrees, Data.DB,
  Datasnap.DBClient, Vcl.Grids, Vcl.DBGrids, Vcl.Mask, Vcl.DBCtrls, PWM_VST,
  System.ImageList, Vcl.ImgList;

type
  pVTNodeData = ^rVTNodeData; // Zeiger auf die Daten-Struktur
  rVTNodeData = record
         Bezeichnung : String;
         Benutzername : String;
         Passwort : String;
         Info : String;
         isFavorit : Boolean;
         Ordner : String;
         NodeIdx : Integer;
         NodeImageIdx : Integer;
     end;

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
  TMain = class(TForm)
    MenuPanel: TPanel;
    Panel2: TPanel;
    LUser: TLabel;
    PasswortBtn: TButton;
    EinstellBtn: TButton;
    Button3: TButton;
    PageControl1: TPageControl;
    PW_Manager: TTabSheet;
    Options: TTabSheet;
    TabSheet3: TTabSheet;
    VST: TVirtualStringTree;
    SuchenEdit: TEdit;
    LBezeichnung: TLabel;
    LBenutzername: TLabel;
    LPasswort: TLabel;
    LInfo: TLabel;
    SeePWBtn: TBitBtn;
    HidePWBtn: TBitBtn;
    LBenutzerDaten: TLabel;
    SaveDataBtn: TBitBtn;
    AddFolderBtn: TBitBtn;
    DelFolderBtn: TBitBtn;
    ClientDataSet1: TClientDataSet;
    DB_Tabelle: TTabSheet;
    DBGrid1: TDBGrid;
    DataSource1: TDataSource;
    DBEditBezeichnung: TDBEdit;
    DBEditBenutzer: TDBEdit;
    DBEditPasswort: TDBEdit;
    DBMemoInfo: TDBMemo;
    DBCheckBox1: TDBCheckBox;
    ClientDataSet1ID: TAutoIncField;
    ClientDataSet1Bezeichnung: TStringField;
    ClientDataSet1Benutzername: TStringField;
    ClientDataSet1Passwort: TStringField;
    ClientDataSet1Info: TStringField;
    ClientDataSet1isFavorit: TBooleanField;
    ClientDataSet1Ordner: TStringField;
    ClientDataSet1NodeIndex: TIntegerField;
    ClientDataSet1NodeImageIndex: TIntegerField;
    AddNewDatasetBtn: TButton;
    Button1: TButton;
    ImageList1: TImageList;
    AddNodeTest: TButton;
    procedure PasswortBtnClick(Sender: TObject);
    procedure EinstellBtnClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SaveDataBtnClick(Sender: TObject);
    procedure AddFolderBtnClick(Sender: TObject);
    procedure AddNewDatasetBtnClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure VSTGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure VSTGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean;
      var ImageIndex: TImageIndex);
    procedure AddNodeTestClick(Sender: TObject);
    procedure VSTGetHint(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; var LineBreakStyle: TVTTooltipLineBreakStyle;
      var HintText: string);
  private
    AFonts : TFonts;
    DBTree : TDBTree;
    procedure InitNewData;
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Main: TMain;
  XMLFile : String;
  //TODO: Drag and Drop innerhalb des VST

implementation

{$R *.dfm}

//*****************************************************************************
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//Fonts-Klasse
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//*****************************************************************************

{------------------------------------------------------------------------------
Author: Seidel 2020-09-06
-------------------------------------------------------------------------------}
constructor TFonts.Create;
begin
  FTitelColor := clBlack;
  FTitelSize := 12;
  FSchreibenColor := clBlack;
  FSchreibenSize := 10;
  FStandartColor := clScrollBar;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-06
-------------------------------------------------------------------------------}
procedure TFonts.SetColor( aColor : TColor );
begin
  FSchreibenColor := aColor;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-06
-------------------------------------------------------------------------------}
procedure TFonts.SetSize(aSize: Integer);
begin
  FSchreibenSize := aSize;
end;
//*****************************************************************************
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//Fonts-Klasse Ende
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//*****************************************************************************

{------------------------------------------------------------------------------
Author: Seidel 2020-09-06
-------------------------------------------------------------------------------}
procedure TMain.InitNewData;
begin
  ClientDataSet1ID.Value := ClientDataSet1.IndexFieldCount;
  ClientDataSet1Bezeichnung.AsString := 'Bezeichnung eingeben...' ;
  ClientDataSet1Benutzername.AsString := 'Benutzername eingeben...';
  ClientDataSet1Passwort.AsString := 'Passwort eingeben...';
  ClientDataSet1Info.AsString := 'Ihre Notiz';
  ClientDataSet1isFavorit.AsBoolean := false;
  DBCheckBox1.Checked := false;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-06
-------------------------------------------------------------------------------}
procedure TMain.AddFolderBtnClick(Sender: TObject);
begin
//
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-06
-------------------------------------------------------------------------------}
procedure TMain.AddNewDatasetBtnClick(Sender: TObject);
begin
  ClientDataSet1.Insert;
  InitNewData;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-06
-------------------------------------------------------------------------------}
procedure TMain.Button1Click(Sender: TObject);
begin
  ClientDataSet1.Delete;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-06
-------------------------------------------------------------------------------}
procedure TMain.AddNodeTestClick(Sender: TObject);
begin
  DBTree.AddDBNodeAtStandart;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-06
-------------------------------------------------------------------------------}
procedure TMain.Button3Click(Sender: TObject);
begin
  PageControl1.ActivePage := TabSheet3;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-06
-------------------------------------------------------------------------------}
procedure TMain.EinstellBtnClick(Sender: TObject);
begin
  PageControl1.ActivePage := Options;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-06
-------------------------------------------------------------------------------}
procedure TMain.FormCreate(Sender: TObject);
begin
//TODO: Methode hinzufügen welche alle Fonts (Größe) dynamisch ändern lässt

  Application.HintHidePause := 10000;

  DBTree := TDBTree.Create( VST );
  DBTree.Create( VST );
  DBTree.FirstOpen;

  {ClientDataSet1.FileName}XMLFile := 'D:\Delphi embarcadero\Passwort_Manager\DB\Versuch4.xml';
  ClientDataSet1.LoadFromFile( {ClientDataSet1.FileName}XMLFile );
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-06
-------------------------------------------------------------------------------}
procedure TMain.PasswortBtnClick(Sender: TObject);
begin
  PageControl1.ActivePage := PW_Manager;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-06
-------------------------------------------------------------------------------}
procedure TMain.SaveDataBtnClick(Sender: TObject);
begin
//TODO: der Pfad zu der Datei kann in ClientDataSet1.FileName gespeichert werden!
  ClientDataSet1.SaveToFile( {ClientDataSet1.FileName}XMLFile , dfXML);
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-06
-------------------------------------------------------------------------------}
procedure TMain.VSTGetHint(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex; var LineBreakStyle: TVTTooltipLineBreakStyle;
  var HintText: string);
var
pData : pVTNodeData;
begin
  pData := VST.GetNodeData( Node );
  HintText := 'Bezeichnung: ' + pData^.Bezeichnung + sLineBreak
              +'Benutzername: ' +  pData^.Benutzername + sLineBreak
              +'Passwort: ' +  pData^.Passwort + sLineBreak
              +'Typ: ' +  pData^.Ordner + sLineBreak
              +'Nodeindex: ' +  IntToStr ( pData^.NodeIdx ) + sLineBreak
              +'Node-Imageindex: ' + IntToStr (  pData^.NodeImageIdx ) + sLineBreak
              +'Favorit: ' +  BoolToStr ( pData^.isFavorit, true );
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-06
-------------------------------------------------------------------------------}
procedure TMain.VSTGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean;
  var ImageIndex: TImageIndex);
var
pData :pVTNodeData;
begin
  //TODO:Wenn es geht ein paar Sachen auslagern
  pData := VST.GetNodeData( Node );
  if kind in [ikNormal,ikSelected] then
  begin
    if {VST.HasChildren[Node]}VST.GetNodeLevel( Node ) <= 1 then
    begin
      if VST.HasChildren[Node] then
      begin
        if VST.Expanded[Node] then
          ImageIndex := IC_FOLDER_OPEN
        else
          ImageIndex := IC_FOLDER_CLOSE;
      end
      else
        ImageIndex := IC_FOLDER_OPEN;
    end
    else
    begin
      case Kind of
        ikNormal : ImageIndex := IC_KEY;
        ikSelected : ImageIndex := IC_KEY_SEL;
      end
    end;
    pData^.NodeImageIdx := ImageIndex;;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-06
-------------------------------------------------------------------------------}
procedure TMain.VSTGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
var
pData :pVTNodeData;
begin
  pData := VST.GetNodeData( Node );
  CellText := pData^.Bezeichnung;
end;

end.
