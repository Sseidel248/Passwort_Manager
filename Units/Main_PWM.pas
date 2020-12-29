unit Main_PWM;

{******************************************************************************
Hauptprogramm "KiiTree"
Author: Sebastian Seidel

Dient der Erzeugung einer Standalone-Datenbank zur Speicherung der Passwörter
*******************************************************************************}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.StdCtrls, Vcl.Buttons,
  Vcl.ToolWin, Vcl.ComCtrls, Vcl.ExtCtrls, VirtualTrees, Data.DB,
  Datasnap.DBClient, Vcl.Grids, Vcl.DBGrids, Vcl.Mask, Vcl.DBCtrls, PWM_VST,
  System.ImageList, Vcl.ImgList, System.Hash, GradientPanel, WinAPI.ActiveX, System.UITypes,
  DBEditWithTextHint, StringGridEx, Vcl.BaseImageCollection, Vcl.ImageCollection,
  Vcl.VirtualImageList, MyGlassButton;

type
  TMainStates = Set of (
    msChanged,                  //wenn gesetzt, dann hat sich etwas im Bäumchen geändert
    msAutoSave,                 //AutoSave aktivieren
    msMPW_Change,               //gerade am ändern des Masterpasswortes
    msSomethingInClipBrd,       //es wurde etwas von KiiTree in die Zwischenablage gepackt
    msEditAfterNewKiiCreate,    //nachdem ein Kii erzeugt wurde, wird gleich das Editfeld fokosiert
    msHideAsTrayIcon            //zeigt an das die Anwendung sich in der Taskbar rechts befindet
    );

type
  pVTNodeData = ^rVTNodeData; // Zeiger auf die Daten-Struktur
  rVTNodeData = record
         ID : Integer;
         Bezeichnung : String;
         Benutzername : String;
         Passwort : String;
         Info : String;
         isFavorit : Boolean;
         Ordner : String;
         NodeImageIdx : Integer;
         URL : String;
     end;

//type
//  TFonts = class
//    FTitelSize : Integer;
//    FTitelColor : TColor;
//    FSchreibenSize : Integer;
//    FSchreibenColor : TColor;
//    FStandartColor : TColor;
//  private
//    procedure SetColor( aColor : TColor );
//    procedure SetSize ( aSize : Integer );
//  public
//    property TitelSize : Integer read FTitelSize write SetSize;
//    property TitelColor : TColor read FTitelColor write SetColor;
//    property EditSize : Integer read FSchreibenSize write SetSize;
//    property EditColor : TColor read FSchreibenColor write SetColor;
//    property StandartColor : TColor read FStandartColor;
//    constructor Create; virtual;
//  end;

type
  TMain = class(TForm)
    Panel2: TPanel;
    LUser: TLabel;
    PageControl1: TPageControl;
    PW_Manager: TTabSheet;
    Options: TTabSheet;
    PasswortChecker: TTabSheet;
    VST: TVirtualStringTree;
    SuchenEdit: TEdit;
    LBezeichnung: TLabel;
    LBenutzername: TLabel;
    LPasswort: TLabel;
    LInfo: TLabel;
    SeePWBtn: TBitBtn;
    HidePWBtn: TBitBtn;
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
    DBCBFavorit: TDBCheckBox;
    AddNewDatasetBtn: TButton;
    DelDataSetBtn: TButton;
    ILNormal: TImageList;
    AddNodeTest: TButton;
    PopupMenuKiiTree: TPopupMenu;
    NeuerOrdner1: TMenuItem;
    NeuerSchlssel1: TMenuItem;
    N1: TMenuItem;
    ZuFavoritenhinzufgen1: TMenuItem;
    N2: TMenuItem;
    Ordnerlschen1: TMenuItem;
    Schlssellschen1: TMenuItem;
    GBDaten: TGroupBox;
    N3: TMenuItem;
    OrdnerUmbenennen1: TMenuItem;
    loadTest: TButton;
    ClientDataSet1ID: TAutoIncField;
    ClientDataSet1Bezeichnung: TStringField;
    ClientDataSet1Benutzername: TStringField;
    ClientDataSet1Passwort: TStringField;
    ClientDataSet1Info: TStringField;
    ClientDataSet1Ordner: TStringField;
    ClientDataSet1NodeImageIndex: TIntegerField;
    ClientDataSet1isFavorit: TBooleanField;
    saveTest: TButton;
    LHallo: TLabel;
    ClientDataSet1URL: TStringField;
    DBEditURL: TDBEdit;
    LURL: TLabel;
    GBDarstellung: TGroupBox;
    GBAllgemein: TGroupBox;
    GBSicherheit: TGroupBox;
    RGSchriftgreosse: TRadioGroup;
    GBFarbverlauf: TGroupBox;
    CBThemen: TComboBox;
    CBAutoSave: TCheckBox;
    CBZeitImSpeicher: TComboBox;
    LZeitSpeicherErkl: TLabel;
    BMasterPWChange: TButton;
    BErzeugeTAN: TButton;
    GBInfo: TGroupBox;
    LBtnErkl: TLabel;
    RGSymbole: TRadioGroup;
    ILklein: TImageList;
    ILGross: TImageList;
    BDataSetCountTest: TButton;
    BAbisZSortTest: TButton;
    BZbisASortTest: TButton;
    PopupMenuDaten: TPopupMenu;
    PZwischenspeichern: TMenuItem;
    N4: TMenuItem;
    PURLimBrowseOerffnen: TMenuItem;
    ZwischenablageTimer: TTimer;
    GradientPanelMain: TGradientPanel;
    LAutoSaveHinweis: TLabel;
    N5: TMenuItem;
    PasswortinZwischenablage1: TMenuItem;
    BenutzerInZwischenablage1: TMenuItem;
    Einfgen1: TMenuItem;
    PKopieren: TMenuItem;
    BPW_Print: TButton;
    CBEditAfterCreateNewKii: TCheckBox;
    SG: TStringGridEx;
    Panel1: TPanel;
    GBPWHinweis: TGroupBox;
    LPWHinweis: TLabel;
    TrayIconKT: TTrayIcon;
    IL_TB_Menu: TImageList;
    ImageCollection1: TImageCollection;
    VirtualImageList1: TVirtualImageList;
    VirtualImageListTB_Menu: TVirtualImageList;
    Menu_Panel: TGradientPanel;
    CBTestDisableMenuButton: TCheckBox;
    SBSaveKiiTree: TGlassButton;
    SBAddNewKii: TGlassButton;
    SBAddNewFolder: TGlassButton;
    SBDelKii: TGlassButton;
    SBDelFolder: TGlassButton;
    SBAbisZ: TGlassButton;
    SBZbisA: TGlassButton;
    VILHauptmenu: TVirtualImageList;
    SBPasswoerter: TGlassButton;
    SBPasswortCheck: TGlassButton;
    SBEinstellungen: TGlassButton;
    SBAbout: TGlassButton;
    procedure PasswortBtnClick(Sender: TObject);
    procedure EinstellBtnClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SaveDataBtnClick(Sender: TObject);
    procedure AddFolderBtnClick(Sender: TObject);
    procedure AddNewDatasetBtnClick(Sender: TObject);
    procedure DelDataSetBtnClick(Sender: TObject);
    procedure VSTGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure VSTGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean;
      var ImageIndex: TImageIndex);
    procedure AddNodeTestClick(Sender: TObject);
    procedure VSTGetHint(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; var LineBreakStyle: TVTTooltipLineBreakStyle;
      var HintText: string);
    procedure HidePWBtnClick(Sender: TObject);
    procedure SeePWBtnClick(Sender: TObject);
    procedure DBMemoInfoClick(Sender: TObject);
    procedure DBEditBezeichnungExit(Sender: TObject);
    procedure DBEditBenutzerExit(Sender: TObject);
    procedure DBEditPasswortExit(Sender: TObject);
    procedure DBMemoInfoExit(Sender: TObject);
    procedure VSTNodeClick(Sender: TBaseVirtualTree; const HitInfo: THitInfo);
    procedure DBCBFavoritMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure NeuerOrdner1Click(Sender: TObject);
    procedure NeuerSchlssel1Click(Sender: TObject);
    procedure PopupMenuKiiTreePopup(Sender: TObject);
    procedure DelFolderBtnClick(Sender: TObject);
    procedure Ordnerlschen1Click(Sender: TObject);
    procedure Schlssellschen1Click(Sender: TObject);
    procedure OrdnerUmbenennen1Click(Sender: TObject);
    procedure VSTNewText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; NewText: string);
    procedure DBEditBezeichnungKeyPress(Sender: TObject; var Key: Char);
    procedure DBEditBenutzerKeyPress(Sender: TObject; var Key: Char);
    procedure DBEditPasswortKeyPress(Sender: TObject; var Key: Char);
    procedure VSTDblClick(Sender: TObject);
    procedure saveTestClick(Sender: TObject);
    procedure loadTestClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure DBEditBezeichnungDblClick(Sender: TObject);
    procedure DBEditBenutzerDblClick(Sender: TObject);
    procedure DBEditPasswortDblClick(Sender: TObject);
    procedure SuchenEditChange(Sender: TObject);
    procedure DBEditURLDblClick(Sender: TObject);
    procedure DBEditURLExit(Sender: TObject);
    procedure DBEditURLKeyPress(Sender: TObject; var Key: Char);
    procedure DBEditBezeichnungClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SBPasswoerterClick(Sender: TObject);
    procedure SBEinstellungenClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure VSTDragDrop(Sender: TBaseVirtualTree; Source: TObject;
      DataObject: IDataObject; Formats: TFormatArray; Shift: TShiftState;
      Pt: TPoint; var Effect: Integer; Mode: TDropMode);
    procedure VSTDragOver(Sender: TBaseVirtualTree; Source: TObject;
      Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode;
      var Effect: Integer; var Accept: Boolean);
    procedure VSTDragAllowed(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; var Allowed: Boolean);
    procedure DBEditBenutzerClick(Sender: TObject);
    procedure DBEditPasswortClick(Sender: TObject);
    procedure DBEditURLClick(Sender: TObject);
    procedure DBEditBezeichnungEnter(Sender: TObject);
    procedure DBEditBenutzerEnter(Sender: TObject);
    procedure DBEditPasswortEnter(Sender: TObject);
    procedure DBEditURLEnter(Sender: TObject);
    procedure DBMemoInfoEnter(Sender: TObject);
    procedure RGSchriftgreosseClick(Sender: TObject);
    procedure RGSymboleClick(Sender: TObject);
    procedure BDataSetCountTestClick(Sender: TObject);
    procedure VSTCompareNodes(Sender: TBaseVirtualTree; Node1,
      Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
    procedure BAbisZSortTestClick(Sender: TObject);
    procedure BZbisASortTestClick(Sender: TObject);
    procedure BAbisZClick(Sender: TObject);
    procedure BZbisAClick(Sender: TObject);
    procedure PopupMenuDatenPopup(Sender: TObject);
    procedure PZwischenspeichernClick(Sender: TObject);
    procedure ZwischenablageTimerTimer(Sender: TObject);
    procedure CBZeitImSpeicherChange(Sender: TObject);
    procedure SBPasswortCheckClick(Sender: TObject);
    procedure DBMemoInfoDblClick(Sender: TObject);
    procedure ZuFavoritenhinzufgen1Click(Sender: TObject);
    procedure VSTKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure VSTDrawText(Sender: TBaseVirtualTree; TargetCanvas: TCanvas;
      Node: PVirtualNode; Column: TColumnIndex; const Text: string;
      const CellRect: TRect; var DefaultDraw: Boolean);
    procedure VSTPaintText(Sender: TBaseVirtualTree;
      const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      TextType: TVSTTextType);
    procedure VSTBeforeItemErase(Sender: TBaseVirtualTree;
      TargetCanvas: TCanvas; Node: PVirtualNode; ItemRect: TRect;
      var ItemColor: TColor; var EraseAction: TItemEraseAction);
    procedure VSTCreateEditor(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; out EditLink: IVTEditLink);
    procedure VSTEditing(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; var Allowed: Boolean);
    procedure VSTBeforePaint(Sender: TBaseVirtualTree; TargetCanvas: TCanvas);
    procedure CBAutoSaveClick(Sender: TObject);
    procedure BMasterPWChangeMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure BMasterPWChangeMouseLeave(Sender: TObject);
    procedure BErzeugeTANMouseLeave(Sender: TObject);
    procedure BErzeugeTANMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure BErzeugeTANClick(Sender: TObject);
    procedure BMasterPWChangeClick(Sender: TObject);
    procedure PasswortinZwischenablage1Click(Sender: TObject);
    procedure BenutzerInZwischenablage1Click(Sender: TObject);
    procedure SBSaveKiiTreeClick(Sender: TObject);
    procedure SBAddNewKiiClick(Sender: TObject);
    procedure SBAddNewFolderClick(Sender: TObject);
    procedure SBDelKiiClick(Sender: TObject);
    procedure SBDelFolderClick(Sender: TObject);
    procedure SBAbisZClick(Sender: TObject);
    procedure SBZbisAClick(Sender: TObject);
    procedure CBFarbeNachDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure CBThemenChange(Sender: TObject);
    procedure SBAboutClick(Sender: TObject);
    procedure Einfgen1Click(Sender: TObject);
    procedure PKopierenClick(Sender: TObject);
    procedure BPW_PrintClick(Sender: TObject);
    procedure Fill_PW_List( var PWList : TStringlist );
    procedure CBEditAfterCreateNewKiiClick(Sender: TObject);
    procedure SGDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure SGFixedCellClick(Sender: TObject; ACol, ARow: Integer);
    procedure SGMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure CBTestDisableMenuButtonClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormAfterMonitorDpiChanged(Sender: TObject; OldDPI,
      NewDPI: Integer);
  private
//    FFonts : TFonts;
    DBTree : TDBTree;
    FMainStates : TMainStates;
    FBezeichnungOld,
    FBenutzerOld,
    FPasswortOld,
    FURLOld,
    FInfoOld : String;
    FOldRow : Integer;
//    FFirstNewUser : Boolean;
    procedure SetFontSizes( size : Integer );
    procedure SetTreeImageListForSize( Number : Integer );
    procedure InitInfosHints;
    procedure AddNewDataSet;
    procedure InitNewData( pNode : pVirtualNode = nil; AddedInFav : Boolean = false);
    procedure UpdateEntryByNode();
    procedure UpdateNodeByEntry( Sender : TObject );
    procedure EnableDBFields( enable : Boolean );
    procedure UpdateChildrenByEntry;
    procedure LoadKTP( ArchivFileName : String);
    procedure SaveKTP; overload;
//    procedure SavePMPK(FileForArchiv : String); overload;    //erstmal nicht benutzt
    procedure LoadDBNodeStructur;
//    procedure TextDBChange( Edit : TDBEdit; Str : String );  //erstmal nicht benutzt
//    procedure TextDBStandart( Edit : TDBEdit; Str : String );//erstmal nicht benutzt
    procedure TextDBClick( Edit : TDBEdit; Str : String );
    procedure TimerStart;
    procedure MarkSpeedBtn( SelBtn1, SelBtn2, SelBtn3 : Boolean);
//    procedure ColorCBEntry( var Canvas : TCanvas; var Rect : TRect; y : Integer; colorStart, colorMid, colorTo : TColor );
    procedure SetThemeColor( Color1, color2, color3 : TColor );
//    procedure SaveMainIni;
    procedure InitGridHeader;
//    procedure InitMenuBtns;
    procedure FillGrid;
    procedure CheckPasswords;
    Procedure ChangePageControlToKiiTree;
    { Private-Deklarationen }
  public
    function GetMaxID : Integer;
    procedure DoChangeStates( Enter : TMainStates; Leave : TMainStates = [] );
    procedure AddNewKii;
    procedure AddNewFolder;
    procedure DelKii;
    procedure DelFolder;
    property MainStates : TMainStates read FMainStates write FMainStates;
    { Public-Deklarationen }
  end;

var
  Main: TMain;

implementation
{$R *.dfm}
uses
  ZipForge,
  Login_PWM,
  Global_PWM,
  Hash_Functions,
  {$IFNDEF TESTLOGIN}ClipBrd,{$ENDIF}
  About_PWM,
  MPW_Change_PWM,
  {$IFNDEF TESTLOGIN}Printers,{$ENDIF}
  PWCheck_PWM,
  Vcl.Imaging.pngimage,
  PWM_ResizeImages;

//*****************************************************************************
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//Fonts-Klasse
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//*****************************************************************************

//{------------------------------------------------------------------------------
//Author: Seidel 2020-09-06
//-------------------------------------------------------------------------------}
//constructor TFonts.Create;
//begin
//  FTitelColor := clBlack;
//  FTitelSize := 12;
//  FSchreibenColor := clBlack;
//  FSchreibenSize := 10;
//  FStandartColor := clGrayText;
//end;
//
//{------------------------------------------------------------------------------
//Author: Seidel 2020-09-06
//-------------------------------------------------------------------------------}
//procedure TFonts.SetColor( aColor : TColor );
//begin
//  FSchreibenColor := aColor;
//end;
//
//{------------------------------------------------------------------------------
//Author: Seidel 2020-09-06
//-------------------------------------------------------------------------------}
//procedure TFonts.SetSize(aSize: Integer);
//begin
//  FSchreibenSize := aSize;
//end;
//*****************************************************************************
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//Fonts-Klasse Ende
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//*****************************************************************************

{------------------------------------------------------------------------------
Author: Seidel 2020-10-15
-------------------------------------------------------------------------------}
//procedure TMain.SaveMainIni;
//var
//ini : TStringlist;
//begin
//  ini := TStringList.Create;
//  try
//    ini.Values[SC_FIRSTSTART] := BoolToStr( FFirstNewUser );
//    ini.SaveToFile( MainIniPath );
//  finally
//    ini.Free;
//  end;
//end;


{------------------------------------------------------------------------------
Author: Seidel 2020-10-15
-------------------------------------------------------------------------------}
procedure TMain.SetThemeColor( Color1, color2, color3 : TColor );
begin
  Screen.Cursor := crHourGlass;
  try
    GradientPanelMain.Color := color1;
    GradientPanelMain.ColorTo := color2;
    Menu_Panel.Color := color2;
    Menu_Panel.ColorTo := color3;

    SG.GradientStartColor := color3;//Change: Seidel 2020-11-19
    SG.GradientEndColor := color2;

    SBSaveKiiTree.Update;
    SBAddNewKii.Update;
    SBAddNewFolder.Update;
    SBDelKii.Update;
    SBDelFolder.Update;
    SBAbisZ.Update;
    SBZbisA.Update;
//    GradientPanelMain.Refresh;
//    TBMenu.Refresh;
    Refresh;
  finally
    Screen.Cursor := crDefault;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-11-12
-------------------------------------------------------------------------------}
procedure TMain.InitGridHeader;
begin
  SG.Cells[ IC_COL_BEZ,IC_ROW_HEAD ] := 'Bezeichnung';
  SG.Cells[ IC_COL_PWD,IC_ROW_HEAD ] := 'Passwort';
  SG.Cells[ IC_COL_ERG,IC_ROW_HEAD ] := 'Sicherheitsstufe';
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-11-18
-------------------------------------------------------------------------------}
procedure TMain.FillGrid;
var
id, r : integer;
NumOfNodes : Integer;
begin
  NumOfNodes := GetMaxID;
  r := 0;
  for id := 1 to NumOfNodes do
  begin
    if ClientDataSet1.Locate( 'ID', id, [] ) then
    begin
      inc( r );
      SG.Cells[ IC_COL_BEZ,r ] := ClientDataSet1Bezeichnung.AsString;
      SG.Cells[ IC_COL_PWD,r ] := ClientDataSet1Passwort.AsString;
      if ( SG.RowCount -1 ) < r then
      begin
        SG.RowCount := SG.RowCount +1;
      end;
    end;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-12-29
-------------------------------------------------------------------------------}
procedure TMain.CBTestDisableMenuButtonClick(Sender: TObject);
begin
  SBSaveKiiTree.Enabled := CBTestDisableMenuButton.Checked;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-11-18
-------------------------------------------------------------------------------}
procedure TMain.CheckPasswords;
var
ThisPW : String;
r,
PWResult : integer;
begin
  for r := 1 to ( SG.RowCount -1 ) do
  begin
    ThisPW := SG.Cells[ IC_COL_PWD,r ];
    PWResult := TPassworCheck.CheckMyPassword( ThisPW );
    SG.Cells[ IC_COL_ERG,r ] := IntToStr( PWResult );
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-11-19
-------------------------------------------------------------------------------}
Procedure TMain.ChangePageControlToKiiTree;
begin
  if PageControl1.ActivePageIndex <> 0 then
    PageControl1.ActivePageIndex := 0;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-15  verlauf von Dreifarben!
-------------------------------------------------------------------------------}
//procedure TMain.ColorCBEntry( var Canvas : TCanvas; var Rect : TRect; y : Integer; colorStart, colorMid, colorTo : TColor );
//var
//i : Integer;
//x : double;
//RDraw, GDraw, BDraw : Byte;
//R, G, B : Byte;
//RMid, GMid, BMid : Byte;
//RTo, GTo, BTo : Byte;
//
//  function GetLinearRGBValue( RGBValueFrom, RGBValueTo : Byte; x : Double ) : Byte;
//  begin
//    Result := Trunc( x * RGBValueTo + ( 1 - x ) * RGBValueFrom );
//  end;
//
//begin
//  R     := GetRValue( colorStart );
//  G     := GetGValue( colorStart );
//  B     := GetBValue( colorStart );
//
//  RMid  := GetRValue( colorMid );
//  GMid  := GetGValue( colorMid );
//  BMid  := GetBValue( colorMid );
//
//  RTo   := GetRValue( colorTo );
//  GTo   := GetGValue( colorTo );
//  BTo   := GetBValue( colorTo );
//
//  for i := ( Rect.Left - 1 )  to ( Rect.Right - 1 ) do
//  begin
//     //Porzentualer Anteil wo sich der Stift befindet
//    if i <= ( trunc( Rect.Right/2 ) ) then
//    begin
//      x := ( 2*i / (Rect.Right) ) ;
//      RDraw := GetLinearRGBValue( R, RMid, x );
//      GDraw := GetLinearRGBValue( G, GMid, x );
//      BDraw := GetLinearRGBValue( B, BMid, x );
//    end
//    else
//    begin
//      x := ( 2*i / (Rect.Right) ) - 1 ;
//      RDraw := GetLinearRGBValue( RMid, RTo, x );
//      GDraw := GetLinearRGBValue( GMid, GTo, x );
//      BDraw := GetLinearRGBValue( BMid, BTo, x );
//    end;
//    Canvas.Pen.Color := RGB( RDraw, GDraw, BDraw );
//    Canvas.MoveTo( i, Rect.Height*y );
//    Canvas.LineTo( i, Rect.Height*(1+y) );
//  end;
//  Canvas.FillRect( Rect );
//
//end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-03
-------------------------------------------------------------------------------}
procedure TMain.UpdateEntryByNode;
var
pNode : PVirtualNode;
pData,
pParentData : pVTNodeData;
begin
  pNode := DBTree.AVST.FocusedNode;
  pData := DBTree.AVST.GetNodeData( pNode );
  pParentData := DBTree.AVST.GetNodeData( pNode.Parent );

  if ClientDataSet1.Locate( 'ID', pData^.ID, [] ) then //Change 2020-10-12
  begin
    ClientDataSet1.Edit;

    ClientDataSet1isFavorit.AsBoolean := pParentData^.Bezeichnung.Equals( SC_FAVORITEN );

    ClientDataSet1Ordner.AsString := pParentData^.Bezeichnung;

    DoChangeStates( [msChanged] );
  end;

  DBTree.AVST.Repaint;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-16
-------------------------------------------------------------------------------}
procedure TMain.UpdateNodeByEntry( Sender : TObject );
var
pNode : PVirtualNode;
pData, pParentData : pVTNodeData;
begin
  pNode := DBTree.AVST.FocusedNode;
  pData := DBTree.AVST.GetNodeData( pNode );

  if ClientDataSet1.Locate( 'ID', pData^.ID, [] ) then
  begin
    ClientDataSet1.Edit;

    if (Sender as TComponent).Name = 'DBEditBezeichnung' then
      pData^.Bezeichnung := ClientDataSet1Bezeichnung.AsString

    else if (Sender as TComponent).Name = 'DBEditBenutzer' then
      pData^.Benutzername := ClientDataSet1Benutzername.AsString

    else if (Sender as TComponent).Name = 'DBEditPasswort' then
      pData^.Passwort := ClientDataSet1Passwort.AsString

    else if (Sender as TComponent).Name = 'DBMemoInfo' then
      pData^.Info := ClientDataSet1Info.AsString

    else if (Sender as TComponent).Name = 'DBCheckBox1' then
      pData^.isFavorit := DBCBFavorit.Checked;

    if ClientDataSet1NodeImageIndex.AsInteger <> pData^.NodeImageIdx then
      ClientDataSet1NodeImageIndex.AsInteger := pData^.NodeImageIdx;

    pParentData := DBTree.AVST.GetNodeData( pNode.Parent );
    if ClientDataSet1Ordner.AsString <> pParentData^.Bezeichnung then
      ClientDataSet1Ordner.AsString := pParentData^.Bezeichnung;

    DoChangeStates( [msChanged] );
  end;
  DBTree.AVST.Repaint;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-18
-------------------------------------------------------------------------------}
procedure TMain.LoadKTP( ArchivFileName : String );
var
  archiver : TZipForge;
  ArchivPath : String;
//  FileForArchiv : String;
  archivItem : TZFArchiveItem;
  stream : TMemoryStream;
  iniList : TStringlist;
begin
  //Ort der Gespeicherten und verschlüsselten Datei
//  ArchivPath := ExtractFileDir( ParamStr(0) ) + '\PM_DB\';
  ArchivPath := GetActualSavePath;
  // Create an instance of the TZipForge class
  archiver := TZipForge.Create(nil);
  //erzeugt den Stream aus dem die DB aufgebaut wird
  stream := TMemoryStream.Create;
  iniList := TStringList.Create;
  try
    with archiver do
    begin
      // Set the name of the archive file we want to create
      //TODO: später soll abhängig vom User die jeweilige KTP Datei genommen werden
      FileName := ArchivPath + ArchivFileName;

      OpenArchive(fmOpenReadWrite);
      // Set base (default) directory for all archive operations
      BaseDir := DefaultSettings.DefaultDBPath; //ExtractFileDir( ParamStr(0) ) + '\PM_DB\';
      // Set encryption algorithm and password
      EncryptionMethod := caAES_256;
  //    Password := TLogin.MD5String( PM_PW ); //Change 2020.09.28
  //    Password := SHA256String( PM_PW ); //Change 2020.10.03
      Password := AnsiString( GetCryptStr( PM_PW, UserData.User, UserData.PW_Str ) );
      // by specifying its absolute path
      if FindFirst('*.xml', archivItem, faAnyFile-faDirectory) then
      begin
        if IsFilePasswordValid( ArchivItem.FileName, Password ) then //Change 2020-10-10
        begin
          stream.Clear;
          stream.Position := 0;
          ExtractToStream( archivItem.FileName, stream );
          stream.Position := 0;
          ClientDataSet1.LoadFromStream( stream );
        end;
      end;
      if FindFirst( '*.ini', archivItem, faAnyFile-faDirectory ) then
      begin
        if IsFilePasswordValid( ArchivItem.FileName, Password ) then
        begin
          stream.Clear;
          stream.Position := 0;
          ExtractToStream( archivItem.FileName, stream );
          stream.Position := 0;
          iniList.LoadFromStream( stream );
          UserData.LoadUserData( iniList );
        end;
      end;
      CloseArchive();
    end;
  finally
    stream.Free;
    iniList.Free;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-18
-------------------------------------------------------------------------------}
procedure TMain.loadTestClick(Sender: TObject);
begin
  LoadKTP('test.KTP');
  LoadDBNodeStructur;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-19
-------------------------------------------------------------------------------}
procedure TMain.LoadDBNodeStructur;
var
Nodes : TVTVirtualNodeEnumeration;
FolderNameList : TStringList;
  I, Max_ID: Integer;
begin
  Nodes := DBTree.AVST.Nodes();

  //Max-Wert der ID's finden
  Max_ID := GetMaxID;

  //Sammeln aller Ordnernamen in der Datenbank
  FolderNameList := TStringList.Create;
  for I := 0 to Max_ID do
  begin
    if ClientDataSet1.Locate( 'ID', I+1, [] ) then
      FolderNameList.Add( ClientDataSet1Ordner.AsString );
  end;

  DBTree.LoadNodes( Nodes, FolderNameList, ClientDataSet1 );

  DBTree.AVST.FullExpand();
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-28
-------------------------------------------------------------------------------}
//procedure TMain.TextDBChange( Edit : TDBEdit; Str : String );
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
Author: Seidel 2020-09-28
-------------------------------------------------------------------------------}
//procedure TMain.TextDBStandart( Edit : TDBEdit; Str : String );
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
//end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-30
-------------------------------------------------------------------------------}
procedure TMain.DoChangeStates( Enter : TMainStates; Leave : TMainStates = [] );
begin
  FMainStates := FMainStates + Enter - Leave;

  if msChanged in MainStates then //hat sich etwas geändert
  begin
    if msAutoSave in MainStates then //prüfe auf Autosave
      SaveKTP
    else
    begin
      Main.Caption := '*KiiTree von ' + UserData.User;
      SBSaveKiiTree.Enabled := true;
//      SaveDataBtn.Enabled := true;
    end;
  end
  else
  begin
    Main.Caption := 'KiiTree von ' + UserData.User;
    SBSaveKiiTree.Enabled := false//Change: Seidel 2020-12-25
//    SaveDataBtn.Enabled := false;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-14
-------------------------------------------------------------------------------}
procedure TMain.AddNewKii;
begin
  DoChangeStates( [msChanged] );
  AddNewDataSet;
  EnableDBFields( true );

  if {StrToBoolDef( UserData.FocusEditAfterNewKii, false )}msEditAfterNewKiiCreate in MainStates then//Change: Seidel 2020-10-28
  begin
    DBEditBezeichnung.SetFocus;
    DBEditBezeichnung.SelectAll;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-15
-------------------------------------------------------------------------------}
procedure TMain.AddNewFolder;
begin
  DBTree.AddDBNodeFolder;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-15
-------------------------------------------------------------------------------}
procedure TMain.DelKii;
var
pNode :PVirtualNode;
begin
  pNode := DBTRee.AVST.FocusedNode;
  if DBTree.AVST.GetNodeLevel( pNode ) = 2 then
  begin
    DBTree.DelDBNode;
    DoChangeStates( [msChanged] );//Change: Seidel 2020-11-18 Speichern nachdem man gelöscht hat nicht davor
    EnableDBFields( false );
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-15
-------------------------------------------------------------------------------}
procedure TMain.DelFolder;
var
pNode :PVirtualNode;
begin
  pNode := DBTRee.AVST.FocusedNode;
  if DBTree.AVST.GetNodeLevel( pNode ) = 1 then
  begin
    DBtree.DelFolder;
    DoChangeStates( [msChanged] );//Change: Seidel 2020-11-18 Speichern nachdem man gelöscht hat nicht davor
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-28
-------------------------------------------------------------------------------}
procedure TMain.TextDBClick( Edit : TDBEdit; Str : String );
var
EditText : String;
begin
  EditText := Edit.Text;
  if EditText.Equals( Str ) then
    Edit.SelectAll;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-18
-------------------------------------------------------------------------------}
procedure TMain.TimerStart;
begin
  if CBZeitImSpeicher.ItemIndex <> 3 then
  begin
    ZwischenablageTimer.Enabled := false;
    ZwischenablageTimer.Enabled := true;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-11
-------------------------------------------------------------------------------}
procedure TMain.MarkSpeedBtn( SelBtn1, SelBtn2, SelBtn3 : Boolean);
begin
  if SelBtn1 then
    SBPasswoerter.Font.Style := [fsBold]
  else
    SBPasswoerter.Font.Style := [];
  if SelBtn3 then
    SBEinstellungen.Font.Style := [fsBold]
  else
    SBEinstellungen.Font.Style := [];
  if SelBtn2 then
    SBPasswortCheck.Font.Style := [fsBold]
  else
    SBPasswortCheck.Font.Style := [];

  SBPasswoerter.Refresh;
  SBEinstellungen.Refresh;
  SBPasswortCheck.Refresh;

end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-18
-------------------------------------------------------------------------------}
procedure TMain.SaveKTP;

  function GetChangedDir: String;
  var
  OpenDialog : TFileOpenDialog;
  begin
    OpenDialog := TFileOpenDialog.Create( Application );
    try
      OpenDialog.Options := [fdoPickFolders];
      OpenDialog.Title := 'Wählen Sie ihren letzten Speicherpfad';
      if OpenDialog.Execute then
        Result := OpenDialog.FileName
      else
        Result := '';
    finally
      OpenDialog.Free;
    end;
  end;

var
  archiver : TZipForge;
  Text : String;
//  ArchivFile : String;
  KiiTreeForArchiv : String;
  IniForArchiv : String;
  SavePath : String;
//  FileToSave : String;
  stream : TMemoryStream;
  IniList : TStringlist;
begin
  //stream erzeugen worin der CDS gespeichert wird
  Screen.Cursor := crAppStart;
  try
    stream := TMemoryStream.Create;
    stream.Clear;
    stream.Position := 0;
    ClientDataSet1.SaveToStream( stream );
    stream.Position := 0;

    //erzeugen des Speicherpfades (dieser ist abhängig vvon der .Exe)
  //  SavePath := ExtractFileDir( ParamStr(0) ) + '\PM_DB\' ;
  //  SavePath := UserData.AppSavePath;
    SavePath := GetActualSavePath;

    if not DirectoryExists( SavePath ) then
      ForceDirectories( SavePath );

    KiiTreeForArchiv := 'PMTable.xml';
    IniForArchiv := 'PM.ini';
    // erzeugen der IniStringlist
    iniList := TStringList.Create;
    try
      //speichern der user daten
      UserData.SaveUserData( IniList );
      //ini-ende

      // Create an instance of the TZipForge class
      archiver := TZipForge.Create(nil);
      with archiver do
      begin
        // Name des Archives was wir erstellen wollen
        FileName := SavePath + UserData.KTP_Name_MD5;
        // das alte Archiv mit dem alten Masterpasswort wird überschrieben
        //hat den Vorteil, wenn die KiiTree Datei gelöscht wurde, wird diese trotzdem neu erstellt!! <--!
        try//Change: Seidel 2020-11-29 prüfen ob ein Speichermedium entfernt wurde
          OpenArchive( fmCreate );
        except
          Text := 'Ihr Speicherpfad' + sLineBreak + '"' + SavePath + '"' + sLineBreak + 'existiert nicht mehr!'
                + sLineBreak + 'Bitte prüfen Sie, ob Ihr Speichermedium vorhanden ist bevor Sie speichern.';
          if MessageDlg( Text, mtError, [mbCancel, mbRetry], 0, mbRetry ) = mrRetry then
          begin
            SaveKTP;//rekursiver aufruf
            archiver.Free;//verhindert dass das zuvorgeöffnete Archiv offenbleibt
          end;
          Exit;
        end;
        // Setzen des Verzeichnisses in dem das Archiv platziert wird
        BaseDir := SavePath;
        // Set encryption algorithm and password
        EncryptionMethod := caAES_256;
  //      Password :=  TLogin.MD5String( PM_PW ); //Change 2020.09.28
  //      Password :=  SHA256String( PM_PW );
        Password := AnsiString( GetCryptStr( PM_PW, UserData.User, UserData.PW_Str ) );
        //hinzufügen einer Datei
        AddFromStream( KiiTreeForArchiv, stream );
        AddFromString( IniForArchiv, IniList.Text );

        //Speicherdialog {Debug}
  //      ShowMessage( FileForArchiv + ' und ' + IniForArchiv + ' wurde in ' + FileName + ' gepackt' );
        //Speicherdialog {Debug} - Ende -
        //Testet das erstellte Archiv und repariert es ggf.
        try
          TestFiles( '*.*' );
        except
          RepairArchive;
        end;

        //Speicherdialog {Debug}
        if ( not ( msAutoSave in MainStates ) ) and ( not ( msMPW_Change in MainStates ) ) then
          ShowMessage( 'Ihr KiiTree wurde erfolgreich in gepackt und gespeichert!' )
        else
        if msMPW_Change in MainStates then
          ShowMessage( 'Ihr Masterpasswort wurde erfolgreich geändert!' );
        //Speicherdialog {Debug} - Ende -

        CloseArchive();
      end;
    finally
      IniList.Free;
    end;
  finally
    Screen.Cursor := crDefault
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-18
-------------------------------------------------------------------------------}
//procedure TMain.SavePMPK(FileForArchiv : String);
//var
//  archiver : TZipForge;
////  ArchivFile : String;
//  SavePath : String;
////  FileToSave : String;
//  stream : TMemoryStream;
//begin
//  //stream erzeugen worin der CDS gespeichert wird
//  stream := TMemoryStream.Create;
//  stream.Clear;
//  stream.Position := 0;
//  ClientDataSet1.SaveToStream( stream );
//  stream.Position := 0;
//
//  //erzeugen des Speicherpfades (dieser ist abhängig vvon der .Exe)
//  SavePath := ExtractFileDir( ParamStr(0) ) + '\PM_DB\' ;
//  if not DirectoryExists( SavePath ) then
//    ForceDirectories( SavePath );
//
//  // Create an instance of the TZipForge class
//  archiver := TZipForge.Create(nil);
//  with archiver do
//  begin
//    // Name des Archives was wir erstellen wollen
//    FileName := SavePath + 'test.KTP';
//    // Because we create a new archive,
//    // we set Mode to fmCreate
//    OpenArchive(fmOpenReadWrite);
//    // Setzen des Verzeichnisses in dem das Archiv platziert wird
//    BaseDir := SavePath;
//    // Set encryption algorithm and password
//    EncryptionMethod := caAES_256;
////    Password :=  TLogin.MD5String( PM_PW );  //Change 2020.09.28
////    Password := SHA256String( PM_PW );
//    Password := AnsiString( GetCryptStr( PM_PW, UserData.User, UserData.PW_Str ) );
//    //hinzufügen einer Datei
//    AddFromStream( FileForArchiv, stream);
//    //AddFiles( FileForArchiv );
//    ShowMessage( FileForArchiv + ' wurde in ' + FileName + ' gepackt' );
//    CloseArchive();
//  end;
//
//end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-02
-------------------------------------------------------------------------------}
function TMain.GetMaxID : Integer;
begin
  if ClientDataSet1.RecordCount <> 0 then //Change 2020-10-11
    try
      ClientDataSet1.AggregatesActive := true;
      Result := ClientDataSet1.Aggregates[0].Value;
    finally
      ClientDataSet1.AggregatesActive := false;
    end
  else
    Result := 0;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-18
-------------------------------------------------------------------------------}
procedure TMain.saveTestClick(Sender: TObject);
begin
  SaveKTP;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-18
-------------------------------------------------------------------------------}
procedure TMain.UpdateChildrenByEntry;
var
pData, pDataChild : pVTNodeData;
pNode, pChild : PVirtualNode;
Children : TVTVirtualNodeEnumeration;
begin
  pNode := DBTree.AVST.FocusedNode;
  if DBTree.AVST.HasChildren[ pNode ] then
  begin
    pData := DBTree.AVST.GetNodeData( pNode );
    Children := DBTree.AVST.ChildNodes( pNode ); //holt alle Children von den umbenannten Ordner
    for pChild in Children do
    begin
      pDataChild := DBTree.AVST.GetNodeData( pChild );
      if ClientDataSet1.Locate('ID', pDataChild^.ID, [] ) then     //sucht den passenden Datensatz
      begin
        ClientDataSet1.Edit;                                  //stellt die DB auf editieren
        ClientDataSet1Ordner.AsString := pData^.Bezeichnung;  //und benennt sie hier neu
      end;
    end;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-16
-------------------------------------------------------------------------------}
procedure TMain.EnableDBFields( enable : Boolean );
begin
  DBEditBezeichnung.Enabled := enable;
  DBEditBenutzer.Enabled := enable;
  DBEditPasswort.Enabled := enable;
  DBMemoInfo.Enabled := enable;
  DBCBFavorit.Enabled := enable;
  DBEditURL.Enabled := enable;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-04
-------------------------------------------------------------------------------}
procedure TMain.SetFontSizes( size : Integer );
begin
  Screen.Cursor := crHourGlass;
  try
    //kleineren
    //Menüleiste
    LHallo.Font.Size := size;
    SBAbout.Font.Size := size;
    //Einstellungen
    GBDarstellung.Font.Size := size;
    GBAllgemein.Font.Size := size;
    GBSicherheit.Font.Size := size;
    GBFarbverlauf.Font.Size := size;
    GBInfo.Font.Size := size;
    BMasterPWChange.Font.Size := size;
    BErzeugeTAN.Font.Size := size;
    LBtnErkl.Font.Size := size;
    CBAutoSave.Font.Size := size;
    CBZeitImSpeicher.Font.Size := size;
    LZeitSpeicherErkl.Font.Size := size;
    RGSchriftgreosse.Font.Size := size;
    RGSymbole.Font.Size := size;
    LAutoSaveHinweis.Font.Size := size;
    CBEditAfterCreateNewKii.Font.Size := Size;
    BPW_Print.Font.Size := Size;
    //Passwörter
    SuchenEdit.Font.Size := size;
    DBTree.AVST.Font.Size := size;
    DBEditBezeichnung.Font.Size := size;
    DBEditBenutzer.Font.Size := size;
    DBEditPasswort.Font.Size := size;
    DBMemoInfo.Font.Size := size;
    DBCBFavorit.Font.Size := size;
    DBEditURL.Font.Size := size;
    LBezeichnung.Font.Size := size;
    LBenutzername.Font.Size := size;
    LPasswort.Font.Size := size;
    LInfo.Font.Size := size;
    LURL.Font.Size := size;

    //KiiChecker//Change: Seidel 2020-11-18
    SG.Font.Size := size;
    GBPWHinweis.Font.Size := Size;
    LPWHinweis.Font.Size := Size;

    //größere
    //Menüleiste
    LUser.Font.Size := size+2;
    SBPasswoerter.Font.Size := size+2;
    SBEinstellungen.Font.Size := size+2;
    SBPasswortCheck.Font.Size := size+2;
    //Passwörter
    GBDaten.Font.Size := size+2;

    //Anpassungen
//    if size > 10 then
//      LBenutzername.Caption := 'Benutzer-' + sLineBreak + 'name:'
//    else
//      LBenutzername.Caption := 'Benutzername:';
    Refresh;
  finally
    Screen.Cursor := crDefault;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-04
-------------------------------------------------------------------------------}
procedure TMain.SetTreeImageListForSize( Number : Integer );
var
Nodes : TVTVirtualNodeEnumeration;
Node : PVirtualNode;
begin
  Nodes := DBTree.AVST.Nodes();
  Screen.Cursor := crHourGlass;
  try
    case Number of
      0: begin
//        DBTree.AVST.Images := ILGross;
        for Node in Nodes do
        begin
          DBTree.AVST.NodeHeight[ Node ] := 36;
        end;
        DBTree.AVST.DefaultNodeHeight := 36;//Change: Seidel 2020-11-26 vergrößert bei Start die Node Größe
      end;
      1: begin
//        DBTree.AVST.Images := ILNormal;
        for Node in Nodes do
        begin
          DBTree.AVST.NodeHeight[ Node ] := 26;
        end;
        DBTree.AVST.DefaultNodeHeight := 26;//Change: Seidel 2020-11-26
      end;
      2: begin
//        DBTree.AVST.Images := ILklein;
        for Node in Nodes do
        begin
          DBTree.AVST.NodeHeight[ Node ] := 18;
        end;
        DBTree.AVST.DefaultNodeHeight := 18;//Change: Seidel 2020-11-26
      end;
    end;
    Refresh;
  finally
    Screen.Cursor := crDefault;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-11-18
-------------------------------------------------------------------------------}
procedure TMain.SGDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
  State: TGridDrawState);
var
ResultStr : String;
Rect2 : TRect;
begin
with SG.Canvas do
  begin
    if ( ARow > IC_ROW_HEAD ) and ( ACol = IC_COL_ERG ) then
    begin
      Rect2 := SG.CellRect( ACol,ARow );//Change: Seidel 2020-11-19 Besseres Ausfüllen der Zelle

      if SG.Cells[ ACol,ARow ].Equals('1') then
      begin
        Brush.Color:= clRed;
        ResultStr := 'Sehr schwach';
      end
      else
      if SG.Cells[ ACol,ARow ].Equals('2') then
      begin
        Brush.Color:= clWebOrange;
        ResultStr := 'Schwach';
      end
      else
      if SG.Cells[ ACol,ARow ].Equals('3') then
      begin
        Brush.Color:= clYellow;
        ResultStr := 'Mäßig';
      end
      else
      if SG.Cells[ ACol,ARow ].Equals('4') then
      begin
        Brush.Color:= clWebGreenYellow;
        ResultStr := 'Stark';
      end
      else
      if SG.Cells[ ACol,ARow ].Equals('5') then
      begin
        Brush.Color:= clGreen;
        ResultStr := 'Sehr stark';
      end;

      FillRect( Rect2 );

      TextOut( Rect2.Left+6, Rect2.Top+6, ResultStr );
    end;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-11-18
-------------------------------------------------------------------------------}
procedure TMain.SGFixedCellClick(Sender: TObject; ACol, ARow: Integer);
begin
  SG.Sort( ACol );
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-11-19
-------------------------------------------------------------------------------}
procedure TMain.SGMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);

  function GetResultDeskription( ARow : Integer ): String;
  var
  s : String;
  begin
    s := SG.Cells[ IC_COL_ERG,ARow ];
    if S.Equals('1') then
      Result := 'Qualität: Sehr schwach' + sLineBreak + 'Ihr Passwort ist kleiner als 8 Zeichen!'
    else
    if S.Equals('2') then
      Result := 'Qualität: Schwach' + sLineBreak + 'Ihr Passwort enthält nur Zeichen eines Zeichentyps!'
    else
    if S.Equals('3') then
      Result := 'Qualität: Mäßig' + sLineBreak + 'Ihr Passwort enthält nur Buchstaben!'
    else
    if S.Equals('4') then
      Result := 'Qualität: Stark' + sLineBreak + 'Ihr Passwort enthält noch keine Sonderzeichen!'
    else
    if S.Equals('5') then
      Result := 'Qualität: Sehr stark' + sLineBreak + 'Ihr Passwort enthält viele verschiedene Zeichentypen!';
  end;

  procedure ShowCellHint( X, Y : Integer );
  var
  ACol, ARow : Integer;
  begin
    //Col und Row Position lesen
    SG.MouseToCell( X, Y, ACol, ARow );
    if FOldRow <> ARow then
    begin
      Application.CancelHint;
      FOldRow := ARow;
    end;
    //wenn im gültigen Bereich zeige Zelleninhalt als Hint
    If ( ACol = IC_COL_ERG ) And ( ARow <> -1 ) Then
      SG.Hint:=GetResultDeskription( ARow )
    else
      Application.CancelHint;
  end;

begin
  ShowCellHint( X, Y );
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-04
-------------------------------------------------------------------------------}
procedure TMain.InitInfosHints;
begin
  SBPasswortCheck.Hint := 'Überprüft Ihre Passwörter nach ihre der Stärke.';
  CBZeitImSpeicher.Hint := 'Nach Ablauf der Zeit, wird der Zwischenspeicher und das darin enthaltene Passwort geleert.';
  LZeitSpeicherErkl.Hint := 'Nach Ablauf der Zeit, wird der Zwischenspeicher und das darin enthaltene Passwort geleert.';
  SBPasswoerter.Hint := 'Hier sind all Ihre Zugangdaten.';
  SBSaveKiiTree.Hint := 'Speichert den KiiTree ( Strg + S )';
  SBAddNewKii.Hint := 'Fügt einen weiteren Schlüssel hinzu ( Strg + N )';
  SBDelKii.Hint := 'Löscht einen markierten Kii ( Entf )';
  SBAddNewFolder.Hint := 'Fügt einen weiteren Ordner hinzu ( Strg + Alt + N )';
  SBDelFolder.Hint := 'Löscht einen markierten Ordner ( Strg + Entf )';
  SBAbisZ.Hint := 'Sortiert die Kii`s aufsteigend';
  SBZbisA.Hint := 'Sortiert die Kii`s absteigend';
  SuchenEdit.Hint := 'Tippen Sie den Namen des Schlüssels ein nachdem Sie suchen möchten.';
  BPW_Print.Hint := 'Druckt Ihre Passwörter als Liste im Querformat aus';
  CBEditAfterCreateNewKii.Hint := 'Nachdem Sie ein Kii erstellt haben, werden die Editierfelder fokosiert';

  //Caption vom AutoSave Hinweis 2020-11-19
  LAutoSaveHinweis.Caption := 'Achtung!' + sLineBreak + 'Das automatisierte speichern beginnt erst bei der nächsten Änderung an ihren KiiTree!';
  LBtnErkl.Visible := false;
  LPWHinweis.Caption := 'Mindestens 8 Zeichen' + sLineBreak
                       +'Mindestens eine Zahl enthalten' + sLineBreak
                       +'Groß und Kleinbuchstaben beinhalten' + sLineBreak
                       +'Mindestens ein Sonderzeichen ( $, %, §, #, +, u.a. ) enthalten';

end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-18
-------------------------------------------------------------------------------}
procedure TMain.AddNewDataSet;
var
pNode, pParentNode : PVirtualNode;
//Data : pVTNodeData;
begin
  //holen das aktuell ausgewählten Nodes
  pParentNode := DBTree.AVST.FocusedNode;
//  Data := DBTree.AVST.GetNodeData( pParentNode );

  ClientDataSet1.Append;
  //in den EditierModus Wechseln
  ClientDataSet1.Edit; //bei einem neuen datensatz brauch nicht geguckt werden ob es den daten satz wirklich gibt
  //erzeugt einen neuen DatenSatz
  if ( DBTree.AVST.GetNodeLevel( pParentNode ) = 1 ) then
  begin
    pNode := DBTree.AddDBNodeAsChildOf( pParentNode );
    if DBTree.IsParentFavFolder( pNode ) then
      InitNewData( pNode, true )
    else
      InitNewData( pNode );
  end
  else
  if ( DBTree.AVST.GetNodeLevel( pParentNode ) = 2 ) then
  begin
    pNode := DBTree.AddDBNodeAsChildOf( pParentNode.Parent );
    InitNewData( pNode );
  end
  else
  begin
    pNode := DBTree.AddDBNodeAtStandart;
    InitNewData( pNode );
  end;
  //dient dem zwischenspeichern der DB Einträge
  ClientDataSet1.Next;
  //dem Node seine DB ID geben
  DBTree.SetNodeDBID( pNode, ClientDataSet1ID.AsInteger );
  //aktiviert die Datensatz Felder
  EnableDBFields( true );
  DBTree.AVST.Selected[ pNode ] := true; //change 2020-10-11
  DBTree.AVST.FocusedNode := pNode;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-06
Change: 2020-09-16
-------------------------------------------------------------------------------}
procedure TMain.InitNewData( pNode : pVirtualNode = nil; AddedInFav : Boolean = false);
var
ParentData, pNodeData : pVTNodeData;
begin

  ClientDataSet1Bezeichnung.AsString := SC_BEZEICHNUNG ;
  ClientDataSet1Benutzername.AsString := SC_BENUTZER;
  ClientDataSet1Passwort.AsString := SC_PASSWORT;
  ClientDataSet1Info.AsString := SC_NOTIZ;
  ClientDataSet1URL.AsString := SC_URL;
  ClientDataSet1isFavorit.AsBoolean := AddedInFav;
  DBCBFavorit.Checked := AddedInFav;

  pNodeData := DBTree.AVST.GetNodeData( pNode );
  if Assigned(pNodeData) then
  begin
    ParentData := DBTree.AVST.GetNodeData( pNode.Parent );

    pNodeData.Bezeichnung := ClientDataSet1Bezeichnung.AsString;
    pNodeData.Benutzername := ClientDataSet1Benutzername.AsString;
    pNodeData.Passwort := ClientDataSet1Passwort.AsString;
    pNodeData.Info := ClientDataSet1Info.AsString;
    pNodeData.isFavorit := ClientDataSet1isFavorit.AsBoolean;
    pNodeData.URL := ClientDataSet1URL.AsString;

    pNodeData.Ordner := ParentData.Bezeichnung;
    ClientDataSet1Ordner.AsString :=  pNodeData.Ordner;

    ClientDataSet1NodeImageIndex.AsInteger := pNodeData^.NodeImageIdx;

    DBTree.TryExpandNode( pNode.Parent );
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-19
-------------------------------------------------------------------------------}
procedure TMain.PKopierenClick(Sender: TObject);
begin
  TimerStart;
  {$IFNDEF TESTLOGIN}
  DoChangeStates( [msSomethingInClipBrd], [] );

  if DBEditBezeichnung.Focused then
    DBEditBezeichnung.CopyToClipboard
  else
  if DBEditBenutzer.Focused then
    DBEditBenutzer.CopyToClipboard
  else
  if DBEditPasswort.Focused then
    DBEditPasswort.CopyToClipboard
  else
  if DBEditURL.Focused then
    DBEditURL.CopyToClipboard
  {$ENDIF}
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-18
-------------------------------------------------------------------------------}
procedure TMain.NeuerOrdner1Click(Sender: TObject);
begin
  if DBTree.AVST.Focused then
    DBTree.AddDBNodeFolder;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-18
-------------------------------------------------------------------------------}
procedure TMain.NeuerSchlssel1Click(Sender: TObject);
begin
//  ShowMessage( 'popup' );
  AddNewKii;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-18
-------------------------------------------------------------------------------}
procedure TMain.Ordnerlschen1Click(Sender: TObject);
begin
  if DBTree.AVST.Focused then
  begin
    DoChangeStates( [msChanged] );
    DBtree.DelFolder;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-18
-------------------------------------------------------------------------------}
procedure TMain.OrdnerUmbenennen1Click(Sender: TObject);
begin
  if DBTree.AVST.Focused then
  begin
    DoChangeStates( [msChanged] );
    DBTree.RenameDBFolder;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-06
-------------------------------------------------------------------------------}
procedure TMain.AddFolderBtnClick(Sender: TObject);
begin
  DoChangeStates( [msChanged] );
  DBTree.AddDBNodeFolder;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-06
-------------------------------------------------------------------------------}
procedure TMain.AddNewDatasetBtnClick(Sender: TObject);
begin
  DoChangeStates( [msChanged] );
  AddNewDataSet;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-06
-------------------------------------------------------------------------------}
procedure TMain.DelDataSetBtnClick(Sender: TObject);
begin
  DoChangeStates( [msChanged] );
  DBTree.DelDBNode;
  EnableDBFields( false );
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-18
-------------------------------------------------------------------------------}
procedure TMain.DelFolderBtnClick(Sender: TObject);
begin
  DoChangeStates( [msChanged] );
  DBTree.DelFolder;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-06 Test zum hinzufügen von Nodes
-------------------------------------------------------------------------------}
procedure TMain.AddNodeTestClick(Sender: TObject);
begin
  DBTree.AddDBNodeAtStandart;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-10
-------------------------------------------------------------------------------}
procedure TMain.BDataSetCountTestClick(Sender: TObject);
var
  I: Integer;
begin
  DBTree.AVST.BeginUpdate;
  for I := 0 to 150 do
  begin
    NeuerSchlssel1Click( nil );
  end;
  DBTree.AVST.EndUpdate;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-14
-------------------------------------------------------------------------------}
procedure TMain.BenutzerInZwischenablage1Click(Sender: TObject);
begin
  TimerStart;
  {$IFNDEF TESTLOGIN}
  DoChangeStates( [msSomethingInClipBrd], [] );
  DBEditBenutzer.SelectAll;
  DBEditBenutzer.CopyToClipboard;
  DBEditBenutzer.SelStart := 0;
  {$ENDIF}
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-**-**
-------------------------------------------------------------------------------}
procedure TMain.BErzeugeTANClick(Sender: TObject);
begin
  //TODO: sicherheits-Tan erzeugen
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-14
-------------------------------------------------------------------------------}
procedure TMain.BErzeugeTANMouseLeave(Sender: TObject);
begin
  LBtnErkl.Visible := false;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-14
-------------------------------------------------------------------------------}
procedure TMain.BErzeugeTANMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  LBtnErkl.Visible := true;
  LBtnErkl.Caption := 'Erzeugen einer Sicherheits-TAN' + sLineBreak + sLineBreak + 'Mit jeder dieser TAN Nummern können Sie sich'
  + ' einmalig anmelden, falls Sie ihr Masterpasswort verlegt oder vergessen haben sollten. Das Masterpasswort sollte'
  + ' danach vorsichtshalber gewechselt werden.';
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-**
-------------------------------------------------------------------------------}
procedure TMain.BMasterPWChangeClick(Sender: TObject);
var
MasterPW_Ch : TMasterPasswortChange;
begin
  MasterPW_Ch := TMasterPasswortChange.Create( nil );
  try
    DoChangeStates( [msMPW_Change] );

    ZwischenablageTimer.Enabled := false;
    MasterPasswortChange.ShowModal;
    if MasterPasswortChange.ModalResult = mrOk then
      SaveKTP;
  finally
    DoChangeStates( [], [msMPW_Change, msChanged] );
    ZwischenablageTimer.Enabled := true;
    MasterPW_Ch.Free;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-14
-------------------------------------------------------------------------------}
procedure TMain.BMasterPWChangeMouseLeave(Sender: TObject);
begin
  LBtnErkl.Visible := false;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-14
-------------------------------------------------------------------------------}
procedure TMain.BMasterPWChangeMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  LBtnErkl.Visible := true;
  LBtnErkl.Caption := 'Änderung des Masterpasswortes' + sLineBreak + sLineBreak + 'Für den bestmöglichen Schutz'
  + ' ändern Sie ihr Masterpasswort regelmäßig und lassen Sie es niemals offen am Arbeitsolatz liegen.';
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-27
-------------------------------------------------------------------------------}
procedure TMain.BPW_PrintClick(Sender: TObject);

  procedure FillPWHeader( const Canvas : TCanvas; posX : Integer; var posY : Integer );
  var
  HeaderList : TStringList;
  N : Integer;
  begin
    HeaderList := TStringlist.Create;
    try

      HeaderList.add( '+------------------------------------------------------------------------------------------------------------------+' );
      HeaderList.add( '|                                                                                                                  |');
      HeaderList.add( '|Hinweis: Bitte die Passwörter gut aufbewahren und nicht freizugänglich liegen lassen.                             |');
      HeaderList.add( '|                                                                                                                  |');
      HeaderList.add( '+------------------------------------------------------------------------------------------------------------------+');
                          //        10        20        30        40        50        60        70        80        90       100       110
                     //12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
      HeaderList.add( 'Bezeichnung                              Benutzername                             Passwort');
                       //(40)+1                                 //(40)+1                                 //(33)+1
      for N := 0 to HeaderList.Count -1  do
      begin
        Canvas.TextOut( posX, posY, HeaderList[N] );
        posY := posY - Canvas.TextHeight( HeaderList[N] );
      end;

    finally
      HeaderList.Free;
    end;
  end;

var
PrintDlg : TPrintDialog;
  I,
//  breite,
  hoehe,
  randLinks,
  randOben,
  randUnten,
  posX,
  posY: Integer;
  PWList : TStringList;
begin
  PWList := TStringList.Create;
  PrintDlg := TPrintDialog.Create( nil );
  try
    Fill_PW_List( PWList );
    if PrintDlg.Execute then
    begin
      {$IFNDEF TESTLOGIN}
      with Printer do
      begin
        Orientation := poLandscape;
        BeginDoc;
        //Millimeter Maßstab
        SetMapMode( Canvas.Handle, MM_LOMETRIC );
        Canvas.Font.Size := 5;//5mm
        Canvas.Font.Name := 'Consolas';
        //Blattgröße in 1/10mm ermitteln
//        breite := GetDeviceCaps( Canvas.Handle, HORZSIZE ) * 10;
        hoehe := GetDeviceCaps( Canvas.Handle, VERTSIZE ) * 10;
        randLinks := 70;
        randOben := 100;
        randUnten := 100;
        posX := randLinks;
        posY := randOben * -1;

        for I := 0 to PWList.Count-1 do
        begin
          if I = 0 then
            FillPWHeader( Canvas, posX, posY );

          if -posY > ( hoehe -( randOben + randUnten ) ) then
          begin
            posY := randOben * -1;
            newPage;
            FillPWHeader( Canvas, posX, posY );
          end;

          Canvas.TextOut( posX, posY, PWList[I] );
          posY := posY - Canvas.TextHeight( PWList[I] );
        end;
        EndDoc;
      end;
      {$ENDIF}
    end;
  finally
    PWList.Free;
    PrintDlg.Free;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-27
-------------------------------------------------------------------------------}
procedure TMain.Fill_PW_List( var PWList : TStringlist );

  procedure ExpandStr( var Str : String; max : Integer = 40 );
  var
  I : Integer;
  begin
    for I := length( Str ) to max do
    begin
      Str := Concat( Str,'.' );
    end;
  end;

var
pNode : PVirtualNode;
pData : pVTNodeData;
BezStr,
BenStr,
PWStr : String;
Nodes : TVTVirtualNodeEnumeration;
begin
  Nodes := DBTree.AVST.Nodes();
  for pNode in Nodes do
  begin
    if DBTree.AVST.GetNodeLevel( pNode ) = 2 then
    begin
      //Node Daten holen
      pData := DBTree.AVST.GetNodeData( pNode );
      //Benutzerdaten zusammenbasteln
      BezStr := pData^.Bezeichnung;
      ExpandStr( BezStr );
      BenStr := pData^.Benutzername;
      ExpandStr( BenStr );
      PWStr := pData^.Passwort;
      ExpandStr( PWStr, 34 );
      //Liste füllen
      PWList.Add( BezStr + BenStr + PWStr );
    end;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-06
-------------------------------------------------------------------------------}
procedure TMain.BAbisZClick(Sender: TObject);
begin
  DBtree.AVST.SortTree( -1, sdAscending );
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-10
-------------------------------------------------------------------------------}
procedure TMain.BAbisZSortTestClick(Sender: TObject);
begin
  DBtree.AVST.SortTree( -1, sdAscending );
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-10
-------------------------------------------------------------------------------}
procedure TMain.Button3Click(Sender: TObject);
begin
  PageControl1.ActivePage := PasswortChecker;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-10
-------------------------------------------------------------------------------}
procedure TMain.BZbisAClick(Sender: TObject);
begin

end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-10
-------------------------------------------------------------------------------}
procedure TMain.BZbisASortTestClick(Sender: TObject);
begin
  DBtree.AVST.SortTree( -1, sdDescending );
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-14
-------------------------------------------------------------------------------}
procedure TMain.CBAutoSaveClick(Sender: TObject);
begin
  if CBAutoSave.Checked then
  begin
    DoChangeStates( [msAutoSave] );
    LAutoSaveHinweis.Visible := true;
  end
  else
  begin
    DoChangeStates( [], [msAutoSave] );
    LAutoSaveHinweis.Visible := false;
  end;
  UserData.AutoSaveChecked := BoolToStr( CBAutoSave.Checked );
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-15
-------------------------------------------------------------------------------}
procedure TMain.CBFarbeNachDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
begin
//  case index of
//    0: CBFarbeNach.Canvas.Brush.Color := clMoneyGreen;
//    1: CBFarbeNach.Canvas.Brush.Color := clWebLightSkyBlue;
//    2: CBFarbeNach.Canvas.Brush.Color := clWebSalmon;
//    3: CBFarbeNach.Canvas.Brush.Color := clWebLightSalmon;
//    4: CBFarbeNach.Canvas.Brush.Color := clWebLightYellow;
//  end;
//  CBFarbeNach.Canvas.fillrect(Rect);
//
//      0: GradientPanel2.Color := clGreen;
//    1: GradientPanel2.Color := clWebMediumBlue;
//    2: GradientPanel2.Color := clWebRed;
//    3: GradientPanel2.Color := clWebDarkOrange;
//    4: GradientPanel2.Color := clWebGold;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-15
-------------------------------------------------------------------------------}
procedure TMain.CBThemenChange(Sender: TObject);
begin
  case CBThemen.ItemIndex of
    0: SetThemeColor( clGreen, clMoneyGreen, clWhite );
    1: SetThemeColor( clWebGoldenRod, clWebMoccasin, clWhite );
    2: SetThemeColor( clWebRed, clWebOrange, clWhite );
    3: SetThemeColor( clWebRoyalBlue, clWebSkyBlue, clWhite );
    4: SetThemeColor( clWebRed, clWebLightYellow, clWhite );
  end;
  UserData.UserTheme := IntToStr ( CBThemen.ItemIndex );
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-28
-------------------------------------------------------------------------------}
procedure TMain.CBEditAfterCreateNewKiiClick(Sender: TObject);
begin
  UserData.FocusEditAfterNewKii := BoolToStr( CBEditAfterCreateNewKii.Checked );
  if CBEditAfterCreateNewKii.Checked then
    DoChangeStates( [msEditAfterNewKiiCreate] )
  else
    DoChangeStates( [], [msEditAfterNewKiiCreate] );
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-18
-------------------------------------------------------------------------------}
procedure TMain.CBZeitImSpeicherChange(Sender: TObject);
begin
  case CBZeitImSpeicher.ItemIndex of
    0:
    begin
      ZwischenablageTimer.Enabled := true;
      ZwischenablageTimer.Interval := 60 * 1000;      //1 min
    end;
    1:
    begin
      ZwischenablageTimer.Enabled := true;
      ZwischenablageTimer.Interval := 5 * 60 * 1000;      //5 min
    end;
    2:
    begin
      ZwischenablageTimer.Enabled := true;
      ZwischenablageTimer.Interval := 10 * 60 * 1000;      //10 min
    end;
    3:
      ZwischenablageTimer.Enabled := false;
  end;
  UserData.ZeitImSpeicher := IntToStr( CBZeitImSpeicher.ItemIndex );
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-17
-------------------------------------------------------------------------------}
procedure TMain.DBCBFavoritMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
pNode{, pParentNode} : PVirtualNode;
//pData, pParentData : pVTNodeData;
//Nodes :TVTVirtualNodeEnumeration;
begin
  //fängt eine Exception beim Start ab
  if not Assigned( DBTree ) then
    Exit;
  //fängt einen Node ab der Nil ist
  pNode := DBTree.AVST.FocusedNode;
  if not Assigned( pNode ) then
    Exit;
  //fängt einen Verschieben eines Ordner ab
  if DBTree.AVST.GetNodeLevel( pNode ) <= 1 then
    Exit;

  if not DBTree.IsParentFavFolder( pNode ) then
    DBTree.MoveNodeToFav( pNode )
  else
    DBTree.MoveNodeTo( pNode, SC_ALLE );

  UpdateNodeByEntry( Sender );
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-03
-------------------------------------------------------------------------------}
procedure TMain.DBEditBenutzerClick(Sender: TObject);
begin
  TextDBClick( DBEditBenutzer, SC_BENUTZER );
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-16
-------------------------------------------------------------------------------}
procedure TMain.DBEditBenutzerDblClick(Sender: TObject);
begin
  DBEditBenutzer.SelectAll;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-16
-------------------------------------------------------------------------------}
procedure TMain.DBEditBenutzerEnter(Sender: TObject);
begin
  FBenutzerOld := DBEditBenutzer.Text;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-04
-------------------------------------------------------------------------------}
procedure TMain.DBEditBenutzerExit(Sender: TObject);
var
ABenutzer : String;
begin
  ABenutzer := DBEditBenutzer.Text;
  if not ABenutzer.Equals( FBenutzerOld ) then
    UpdateNodeByEntry( Sender );
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-18
-------------------------------------------------------------------------------}
procedure TMain.DBEditBenutzerKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    DBEditPasswort.SetFocus;
  end
  else
  if Ord( Key ) = 27 then
  begin
    Key := #0;
    GBDaten.SetFocus;
  end;
  DBTree.AVST.Refresh;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-16
-------------------------------------------------------------------------------}
procedure TMain.DBEditBezeichnungClick(Sender: TObject);
begin
  TextDBClick( DBEditBezeichnung, SC_BEZEICHNUNG );
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-28
-------------------------------------------------------------------------------}
procedure TMain.DBEditBezeichnungDblClick(Sender: TObject);
begin
  DBEditBezeichnung.SelectAll;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-16
-------------------------------------------------------------------------------}
procedure TMain.DBEditBezeichnungEnter(Sender: TObject);
begin
  FBezeichnungOld := DBEditBezeichnung.Text;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-04
-------------------------------------------------------------------------------}
procedure TMain.DBEditBezeichnungExit(Sender: TObject);
var
ABezeichnung : String;
begin
  ABezeichnung := DBEditBezeichnung.Text;
  if not ABezeichnung.Equals( FBezeichnungOld ) then
    UpdateNodeByEntry( Sender );
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-18
-------------------------------------------------------------------------------}
procedure TMain.DBEditBezeichnungKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    DBEditBenutzer.SetFocus;
  end
  else
  if Ord( Key ) = 27 then
  begin
    Key := #0;
    GBDaten.SetFocus;
  end;
  DBTree.AVST.Refresh;
end;


{------------------------------------------------------------------------------
Author: Seidel 2020-10-03
-------------------------------------------------------------------------------}
procedure TMain.DBEditPasswortClick(Sender: TObject);
begin
  TextDBClick( DBEditPasswort, SC_PASSWORT );
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-16
-------------------------------------------------------------------------------}
procedure TMain.DBEditPasswortDblClick(Sender: TObject);
begin
  DBEditPasswort.SelectAll;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-16
-------------------------------------------------------------------------------}
procedure TMain.DBEditPasswortEnter(Sender: TObject);
begin
  FPasswortOld := DBEditPasswort.Text;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-04
-------------------------------------------------------------------------------}
procedure TMain.DBEditPasswortExit(Sender: TObject);
var
APasswort : String;
begin
  APasswort := DBEditPasswort.Text;
  if not APasswort.Equals( FPasswortOld ) then
    UpdateNodeByEntry( Sender );
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-18
-------------------------------------------------------------------------------}
procedure TMain.DBEditPasswortKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    DBEditURL.SetFocus;
  end
  else
  if Ord( Key ) = 27 then
  begin
    Key := #0;
    GBDaten.SetFocus;
  end;
  DBTree.AVST.Refresh;
end;


{------------------------------------------------------------------------------
Author: Seidel 2020-10-03
-------------------------------------------------------------------------------}
procedure TMain.DBEditURLClick(Sender: TObject);
begin
  TextDBClick( DBEditURL, SC_URL );
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-24
-------------------------------------------------------------------------------}
procedure TMain.DBEditURLDblClick(Sender: TObject);
begin
  DBEditURL.SelectAll;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-24
-------------------------------------------------------------------------------}
procedure TMain.DBEditURLEnter(Sender: TObject);
begin
  FURLOld := DBEditURL.Text;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-04
-------------------------------------------------------------------------------}
procedure TMain.DBEditURLExit(Sender: TObject);
var
AURL : String;
begin
  if not AURL.Equals( FURLOld ) then
    UpdateNodeByEntry( Sender );
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-24
-------------------------------------------------------------------------------}
procedure TMain.DBEditURLKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    VST.SetFocus;
  end
  else
  if Ord( Key ) = 27 then //Esc Button
  begin
    Key := #0;
    GBDaten.SetFocus;
  end;
  DBTree.AVST.Refresh;
end;


{------------------------------------------------------------------------------
Author: Seidel 2020-09-16
-------------------------------------------------------------------------------}
procedure TMain.DBMemoInfoClick(Sender: TObject);
var
Text : String;
begin
  Text := DBMemoInfo.Text;
  if Text.Equals( SC_NOTIZ ) then
    DBMemoInfo.SelectAll;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-11
-------------------------------------------------------------------------------}
procedure TMain.DBMemoInfoDblClick(Sender: TObject);
begin
  DBMemoInfo.SelectAll;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-16
-------------------------------------------------------------------------------}
procedure TMain.DBMemoInfoEnter(Sender: TObject);
var
Text : String;
begin
  Text := DBMemoInfo.Text;
  FInfoOld := DBMemoInfo.Text;
  if Text.Equals( SC_NOTIZ ) then
    DBMemoInfo.SelectAll;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-04
-------------------------------------------------------------------------------}
procedure TMain.DBMemoInfoExit(Sender: TObject);
var
AInfo : String;
begin
  if not AInfo.Equals( FInfoOld ) then
  begin
    UpdateNodeByEntry( Sender );
    DBTree.AVST.Refresh;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-19
-------------------------------------------------------------------------------}
procedure TMain.Einfgen1Click(Sender: TObject);
begin
    {$IFNDEF TESTLOGIN}
  if DBEditBezeichnung.Focused then
    DBEditBezeichnung.PasteFromClipboard
  else
  if DBEditBenutzer.Focused then
    DBEditBenutzer.PasteFromClipboard
  else
  if DBEditPasswort.Focused then
    DBEditPasswort.PasteFromClipboard
  else
  if DBEditURL.Focused then
    DBEditURL.PasteFromClipboard
  {$ENDIF}
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-06
-------------------------------------------------------------------------------}
procedure TMain.EinstellBtnClick(Sender: TObject);
begin
  PageControl1.ActivePage := Options;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-12-29
-------------------------------------------------------------------------------}
procedure TMain.FormAfterMonitorDpiChanged(Sender: TObject; OldDPI,
  NewDPI: Integer);

  procedure ScaleBtnFont( Btn : TGlassButton; NewDPI : Integer );
  var
  Faktor : Double;
  begin
    Faktor := NewDPI / 96;
    Btn.Font.Size := Round( SBAbout.Font.Size * Faktor);
    Btn.Refresh;
  end;

begin
  ScaleBtnFont( SBAbout, NewDPI );
  ScaleBtnFont( SBPasswoerter, NewDPI );
  ScaleBtnFont( SBPasswortCheck, NewDPI );
  ScaleBtnFont( SBEinstellungen, NewDPI );
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-11-25
-------------------------------------------------------------------------------}
procedure TMain.FormClose(Sender: TObject; var Action: TCloseAction);
var
Text : String;
MResult : Integer;
begin
    if ( msChanged in MainStates ) and not ( msAutoSave in MainStates ) then
  begin
    Text := 'Es sind Änderungen vorhanden.'
    + sLineBreak
    + 'Sollen die Änderungen an Ihrem KiiTree gespeichert werden?';
    MResult := MessageDlg( Text, mtWarning, [mbYes, mbNo], 0, mbYes );
    if MResult = mrYes then
      SaveKTP;
  end;
  MainIni.SaveSetting;
  if msSomethingInClipBrd in MainStates then//Change: Seidel 2020-11-04
  begin
    Text := 'Soll die Zwischenablage geleert werden bevor Sie die Anwendung schließen?';
    MResult := MessageDlg( Text, mtWarning, [mbYes, mbNo], 0, mbYes );
    if MResult = mrYes then
    {$IFNDEF TESTLOGIN}
      Clipboard.Clear;
    {$ENDIF}
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-11-25
-------------------------------------------------------------------------------}
procedure TMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
//var
//Text : String;
begin
  //TODO: SystemTrayIcon
//  Text := 'Anwendung Schließen oder Minimieren?';
//  if MessageDlg then
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-06
-------------------------------------------------------------------------------}
procedure TMain.FormCreate(Sender: TObject);
//var
//opendialog : TFileOpenDialog;
//PersonalFolder : String;
//I:Integer;
begin
  Application.HintHidePause := 10000;

  {$IFDEF DEBUG}
  DB_Tabelle.TabVisible := true;
  CBTestDisableMenuButton.Visible := true;
  {$ENDIF}
  //TODO: für den Beta Installer; alles was false ist wurde noch nicht implementiert
  BErzeugeTAN.Visible := false;
//  SBPasswortCheck.Enabled := false;
  //Beta Installer - Ende -
  //hole den Pfad zu Eigene Dateien/Dokumente
//  PersonalFolder := GetSpecialFolder( Handle, IC_GET_PERSONAL_FOLDER ) + 'Documents\KiiTree\';

  DefaultSettings.Init( handle );
  //prüft auch ob Schreibrecht vorhanden sind
  if not MainIni.CreateIfNotExist then
    Application.Terminate;

  //setzen der maximalen Länge
  DBEditBezeichnung.MaxLength := ClientDataSet1Bezeichnung.Size;
  DBEditBenutzer.MaxLength := ClientDataSet1Benutzername.Size;
  DBEditPasswort.MaxLength := ClientDataSet1Passwort.Size;

  KeyPreview := true;
  PageControl1.ActivePage := PW_Manager;
  InitInfosHints;
  InitGridHeader;
//  InitMenuBtns;

  DBTree := TDBTree.Create( VST );
  DBTree.Create( VST );
  DBTree.FirstOpen;

  Login := TLogin.Create(nil);
  try
    //StandartOrdner auswählen,jedoch wenn der User einen Speziellen Pfad will dann nim diesen
//    Login.ESavePathForKTPs.Text := PersonalFolder;
//    MainIni.CreateIfNotExist;
    //Login Formular anzeigen und auf Modalresult warten
    Login.ShowModal;
    //Speichern ob first Start
//    FFirstNewUser := Login.CBNewUser.Checked;
//    EmptyXMLFile := AppSettings.DefaultDBPath + 'EmtyTable.xml';
    if Login.ModalResult = mrCancel then // schließen der kompletten anwendung
      Application.Terminate
    else
    begin
      ClientDataSet1.LoadFromFile( DefaultSettings.DefaultDBPath );
      if Login.ModalResult = mrRetry then //erzeugen einer neuen DB ( neuer User )
        DoChangeStates( [msChanged] )  //Change 2020-10-10 Damit gespeichert werden kann
      else if Login.ModalResult = mrOk then//laden einer alten DB
      begin
        LoadKTP( UserData.KTP_Name_MD5 );
        //soll die Node entsprechend der Datenbank erzeugen
        LoadDBNodeStructur;
        //XMLFile := 'D:\Delphie Embarcadero\Passwort_Manager\DB\PMTable6.xml';
      end;
      EnableDBFields( false );
      LUser.Caption := UserData.User;
      Main.Caption := 'KiiTree von ' + UserData.User;
    end;
  finally
    Login.Free;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-28
-------------------------------------------------------------------------------}
procedure TMain.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
//var
//pNode : PVirtualNode;
begin
  if ( Key = 70 ) and ( Shift = [ssCtrl] ) then //Strg + F
  begin
    SuchenEdit.SetFocus;
    SuchenEdit.Clear;
  end
  else
  if ( Key = 78 ) and ( Shift = [ssCtrl] ) then  // Strg + N //Change 2020-10-11
  begin
    if not ( msEditAfterNewKiiCreate in MainStates ) then//Change: Seidel 2020-11-19
    begin
//      pNode := DBTree.GetSelectedNode;
      if ( not DBTree.AVST.Focused ) and ( DBTree.AVST.SelectedCount = 1 ) then
        DBtree.AVST.SetFocus;
    end;

    if ( not NeuerSchlssel1.Enabled ) then
      SBAddNewKiiClick( nil );

  end
  else
  if ( Key = 83 ) and ( Shift = [ssCtrl] ) then  // Strg + S //Change 2020-10-17
  begin
    if SBSaveKiiTree.Enabled then
      SBSaveKiiTreeClick( nil );
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-12-29
-------------------------------------------------------------------------------}
procedure TMain.FormResize(Sender: TObject);
begin
  Main.Invalidate;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-19
-------------------------------------------------------------------------------}
procedure TMain.FormShow(Sender: TObject);
begin

end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-16
-------------------------------------------------------------------------------}
procedure TMain.HidePWBtnClick(Sender: TObject);
begin
  DBEditPasswort.PasswordChar := '*';
  SeePWBtn.Enabled := true;
  HidePWBtn.Enabled := false;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-06
-------------------------------------------------------------------------------}
procedure TMain.PasswortBtnClick(Sender: TObject);
begin
  PageControl1.ActivePage := PW_Manager;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-14
-------------------------------------------------------------------------------}
procedure TMain.PasswortinZwischenablage1Click(Sender: TObject);
begin
  TimerStart;
  {$IFNDEF TESTLOGIN}
  DoChangeStates( [msSomethingInClipBrd], [] );
  DBEditPasswort.SelectAll;
  DBEditPasswort.CopyToClipboard;
  DBEditPasswort.SelStart := 0;
  {$ENDIF}
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-18
-------------------------------------------------------------------------------}
procedure TMain.PopupMenuKiiTreePopup(Sender: TObject);
var
pNode : PVirtualNode;
begin
  pNode := DBTree.AVST.FocusedNode;
  if not Assigned( pNode ) then
  begin
    NeuerSchlssel1.Enabled            := false;
    NeuerOrdner1.Enabled              := true;
    ZuFavoritenhinzufgen1.Enabled     := false;
    Ordnerlschen1.Enabled             := false;
    Schlssellschen1.Enabled           := false;
    OrdnerUmbenennen1.Enabled         := false;
    PasswortinZwischenablage1.Enabled := false;
    BenutzerInZwischenablage1.Enabled := false;
  end
  else
  begin
    //Nodelevel = 1 -> Ordner der einzelnen Schlüssel
    if DBTree.AVST.GetNodeLevel( pNode ) = 1 then
    begin
      if DBTree.IsFavFolder( pNode ) then
      begin
        Ordnerlschen1.Enabled       := false;
        OrdnerUmbenennen1.Enabled   := false;
      end
      else if DBTree.IsAllFolder( pNode ) then
      begin
        Ordnerlschen1.Enabled       := false;
        OrdnerUmbenennen1.Enabled   := false;
      end
      else
      begin
        Ordnerlschen1.Enabled       := true;
        OrdnerUmbenennen1.Enabled   := true;
      end;
      BenutzerInZwischenablage1.Enabled := false;
      PasswortinZwischenablage1.Enabled := false;
      NeuerSchlssel1.Enabled        := true;
      NeuerOrdner1.Enabled          := true;
      ZuFavoritenhinzufgen1.Enabled := false;
      Schlssellschen1.Enabled       := false;
      NeuerOrdner1.Caption := 'Neuer Ordner';
    end
    //Nodelevel = 2 -> Schlüssel in einem Ordner
    else if DBTree.AVST.GetNodeLevel( pNode ) = 2 then
    begin
      NeuerSchlssel1.Enabled        := true;//Change: Seidel 2020-10-28
      NeuerOrdner1.Enabled          := false;
      ZuFavoritenhinzufgen1.Enabled := true;
      Ordnerlschen1.Enabled         := false;
      Schlssellschen1.Enabled       := true;
      OrdnerUmbenennen1.Enabled       := false;
      BenutzerInZwischenablage1.Enabled := true;
      PasswortinZwischenablage1.Enabled := true;
      if DBTree.IsParentFavFolder( pNode ) then
        ZuFavoritenhinzufgen1.Caption := 'Nach "Alle" verschieben'
      else
        ZuFavoritenhinzufgen1.Caption := 'Nach "Favoriten" verschieben';
      NeuerOrdner1.Caption := 'Neuer Ordner';
    end
    //Nodelevel = 0 -> HauptOrdner
    else if DBTree.AVST.GetNodeLevel( pNode ) = 0 then
    begin
      NeuerSchlssel1.Enabled := false;
      //Ordner hinzufügen ist aktiv
      ZuFavoritenhinzufgen1.Enabled := false;
      Ordnerlschen1.Enabled := false;
      Schlssellschen1.Enabled := false;
      OrdnerUmbenennen1.Enabled       := false;
      BenutzerInZwischenablage1.Enabled := false;
      PasswortinZwischenablage1.Enabled := false;
      NeuerOrdner1.Caption := 'Neuer Unterordner';
    end;

  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-10
-------------------------------------------------------------------------------}
procedure TMain.PopupMenuDatenPopup(Sender: TObject);

  procedure ChangePopupDaten( DBEdit : TDBEdit; Caption : String = '' );//Change: Seidel 2020-11-23
  begin
    if DBEdit.Focused then
    begin
      if Caption.Equals( '' ) then
        PZwischenspeichern.Visible := false
      else
      begin
        PZwischenspeichern.Caption := Caption;
        PZwischenspeichern.Visible := true;
      end;

      PURLimBrowseOerffnen.Visible := false;
      if DBEdit.SelLength > 0 then
        PKopieren.Enabled := true
      else
        PKopieren.Enabled := false;
    end;
  end;

begin
  ChangePopupDaten( DBEditBezeichnung );
  ChangePopupDaten( DBEditBenutzer , 'Benutzername in Zwischenablage kopieren' );
  ChangePopupDaten( DBEditPasswort , 'Passwort in Zwischenablage kopieren' );
  ChangePopupDaten( DBEditURL , 'InternetSeite in Zwischenablage kopieren' );
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-10
-------------------------------------------------------------------------------}
procedure TMain.PZwischenspeichernClick(Sender: TObject);
begin
  TimerStart;
  {$IFNDEF TESTLOGIN}
  DoChangeStates( [msSomethingInClipBrd], [] );
  if DBEditBenutzer.Focused then
  begin
    DBEditBenutzer.SelectAll;
    DBEditBenutzer.CopyToClipboard;
    DBEditBenutzer.SelStart := 0;
  end
  else
  if DBEditPasswort.Focused then
  begin
    DBEditPasswort.SelectAll;
    DBEditPasswort.CopyToClipboard;
    DBEditPasswort.SelStart := 0;
  end
  else
  if DBEditURL.Focused then
  begin
    DBEditURL.SelectAll;
    DBEditURL.CopyToClipboard;
    DBEditURL.SelStart := 0;
  end;
  {$ENDIF}
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-04
-------------------------------------------------------------------------------}
procedure TMain.RGSchriftgreosseClick(Sender: TObject);
begin
  case RGSchriftgreosse.ItemIndex of
    0: SetFontSizes( 12 );
    1: SetFontSizes( 10 );
    2: SetFontSizes( 8 );
  end;
  UserData.FontSize := IntToStr( RGSchriftgreosse.ItemIndex );
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-04
-------------------------------------------------------------------------------}
procedure TMain.RGSymboleClick(Sender: TObject);
begin
  //Bildgröße wird über VirtualImageList geregelt
  //RGSymbole deaktiviert //Change: Seidel 2020-12-18
  case RGSymbole.ItemIndex of
    0: SetTreeImageListForSize( 0 );
    1: SetTreeImageListForSize( 1 );
    2: SetTreeImageListForSize( 2 );
  end;
  UserData.SymbolSize := IntToStr( RGSymbole.ItemIndex );
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-06
-------------------------------------------------------------------------------}
procedure TMain.SaveDataBtnClick(Sender: TObject);
begin
  SaveKTP;
  DoChangeStates( [], [msChanged] );
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-15
-------------------------------------------------------------------------------}
procedure TMain.SBAbisZClick(Sender: TObject);
begin
  ChangePageControlToKiiTree;
  DBtree.AVST.SortTree( -1, sdAscending );
end;


procedure TMain.SBAboutClick(Sender: TObject);
begin
  About_Dlg.Show;
end;

procedure TMain.SBAddNewFolderClick(Sender: TObject);
begin
  ChangePageControlToKiiTree;
  AddNewFolder;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-15
-------------------------------------------------------------------------------}
procedure TMain.SBAddNewKiiClick(Sender: TObject);
begin
  ChangePageControlToKiiTree;
  AddNewKii;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-15
-------------------------------------------------------------------------------}
procedure TMain.SBDelFolderClick(Sender: TObject);
begin
  ChangePageControlToKiiTree;
  DelFolder;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-15
-------------------------------------------------------------------------------}
procedure TMain.SBDelKiiClick(Sender: TObject);
begin
 ChangePageControlToKiiTree;
  DelKii;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-30
-------------------------------------------------------------------------------}
procedure TMain.SBEinstellungenClick(Sender: TObject);
begin
  PageControl1.ActivePage := Options;
  MarkSpeedBtn( false, false, true );
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-30
-------------------------------------------------------------------------------}
procedure TMain.SBPasswoerterClick(Sender: TObject);
begin
  PageControl1.ActivePage := PW_Manager;
  MarkSpeedBtn( true, false, false );
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-11
-------------------------------------------------------------------------------}
procedure TMain.SBPasswortCheckClick(Sender: TObject);
begin
  PageControl1.ActivePage := PasswortChecker;
  MarkSpeedBtn( false, true, false );
  FillGrid;
  CheckPasswords;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-11
-------------------------------------------------------------------------------}

procedure TMain.SBSaveKiiTreeClick(Sender: TObject);
begin
  SaveKTP;
  DoChangeStates( [], [msChanged] );
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-11
-------------------------------------------------------------------------------}

procedure TMain.SBZbisAClick(Sender: TObject);
begin
  ChangePageControlToKiiTree;
  DBtree.AVST.SortTree( -1, sdDescending );
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-18
-------------------------------------------------------------------------------}
procedure TMain.Schlssellschen1Click(Sender: TObject);
begin
  if DBTree.AVST.Focused then
  begin
    DBTree.DelDBNode;
    DoChangeStates( [msChanged] );//Change: Seidel 2020-11-18 Speichern nachdem man gelöscht hat nicht davor
    EnableDBFields( false );
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-16
-------------------------------------------------------------------------------}
procedure TMain.SeePWBtnClick(Sender: TObject);
begin
  DBEditPasswort.PasswordChar := #0;
  SeePWBtn.Enabled := false;
  HidePWBtn.Enabled := true;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-21
-------------------------------------------------------------------------------}
procedure TMain.SuchenEditChange(Sender: TObject);
var
SucheText : String;
begin
  SucheText := SuchenEdit.Text;
  if SucheText.Equals( '' ) then
  begin
    DBTree.UnfilterAllTree;
  end
  else
  begin
    DBTree.FilterTree( SucheText );
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-14
-------------------------------------------------------------------------------}
procedure TMain.VSTBeforeItemErase(Sender: TBaseVirtualTree;
  TargetCanvas: TCanvas; Node: PVirtualNode; ItemRect: TRect;
  var ItemColor: TColor; var EraseAction: TItemEraseAction);
begin
  if DBTree.AVST.AbsoluteIndex(Node) mod 2 = 0 then
    ItemColor := clCream
  else
    ItemColor := clWhite;
end;

procedure TMain.VSTBeforePaint(Sender: TBaseVirtualTree; TargetCanvas: TCanvas);
begin

end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-10
-------------------------------------------------------------------------------}
procedure TMain.VSTCompareNodes(Sender: TBaseVirtualTree; Node1,
  Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
var
pData1, pData2 : pVTNodeData;
begin
  if ( DBTree.AVST.GetNodeLevel( Node1 ) = 2 ) and ( DBTree.AVST.GetNodeLevel( Node2 ) = 2 ) then
  begin
    pData1 := DBTree.AVST.GetNodeData( Node1 );
    pData2 := DBTree.AVST.GetNodeData( Node2 );
    if pData1.Bezeichnung < pData2.Bezeichnung then
      Result := -1
    else
    if SameText( pData1.Bezeichnung, pdata2.Bezeichnung ) then
      Result := 0
    else
      Result := 1;
  end;
end;

procedure TMain.VSTCreateEditor(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex; out EditLink: IVTEditLink);
begin

end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-18
-------------------------------------------------------------------------------}
procedure TMain.VSTDblClick(Sender: TObject);
var
pNode : PVirtualNode;
begin
  pNode := DBTree.AVST.FocusedNode;
  if DBTree.AVST.GetNodeLevel( pNode ) = 2 then  //Change 2020-10-12
    DBEditBezeichnung.SetFocus;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-03
-------------------------------------------------------------------------------}
procedure TMain.VSTDragAllowed(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex; var Allowed: Boolean);
begin
  if DBTree.AVST.GetNodeLevel( Node ) = 2 then
    Allowed := true
  else
    Allowed := false;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-03
-------------------------------------------------------------------------------}
procedure TMain.VSTDragDrop(Sender: TBaseVirtualTree; Source: TObject;
  DataObject: IDataObject; Formats: TFormatArray; Shift: TShiftState;
  Pt: TPoint; var Effect: Integer; Mode: TDropMode);
var
AttachMode :TVTNodeAttachMode;
pNode,
pFocusNode,
pParentNodeBeforeDD,
pParentNodeAfterDD : PVirtualNode;
begin
  if ( Sender = Source ) then
  begin
    pFocusNode := DBTree.AVST.FocusedNode; // zu ziehenden Node
    pParentNodeBeforeDD := pFocusNode.Parent; //Elternteil vor dem verschieben
    case Mode of // DropPosition in NodeAttachMode umsetzen
      dmAbove:    AttachMode := amInsertBefore;
      dmOnNode:   AttachMode := amAddChildFirst;
      dmBelow:    AttachMode := amInsertAfter;
      else        AttachMode := amNowhere;
    end;
    pNode := DBTree.AVST.DropTargetNode;

    DBTree.AVST.ProcessDrop( DataObject, pNode, Effect, AttachMode );
    pParentNodeAfterDD := pNode.Parent; //Elternteil nach dem verschieben
    if pParentNodeBeforeDD <> pParentNodeAfterDD then
    begin
      UpdateEntryByNode;
      DBTree.AVST.Expanded[pNode] := true;
    end;
  end
  else
    Effect := DROPEFFECT_NONE;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-03
-------------------------------------------------------------------------------}
procedure TMain.VSTDragOver(Sender: TBaseVirtualTree; Source: TObject;
  Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode;
  var Effect: Integer; var Accept: Boolean);
var
Node : PVirtualNode;
begin
  Node := DBTree.AVST.DropTargetNode;
  case DBTree.AVST.GetNodeLevel( Node ) of
    1: Accept := true;
    2: begin
      case Mode of // DropPosition in NodeAttachMode umsetzen
        dmAbove:    Accept := true;
        dmOnNode:   Accept := false;
        dmBelow:    Accept := true;
      end;
    end
    else
    begin
      Accept := false;
    end;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-14
-------------------------------------------------------------------------------}
procedure TMain.VSTDrawText(Sender: TBaseVirtualTree; TargetCanvas: TCanvas;
  Node: PVirtualNode; Column: TColumnIndex; const Text: string;
  const CellRect: TRect; var DefaultDraw: Boolean);
//var
//  CC: TCanvas;
//  OldFontSize : Integer;
//  CCRect : TRect;
//  text1 : String;
begin
//  Über eine Ableitung einbauen!! Drawtext()

//  text1 := '<Hallo, das ist ein Test für einen Langen Hinweis>';
//  OldFontSize := Font.Size;
//  CCRect := Self.ClientRect;//Rect( 0, 0, ClientWidth, ClientHeight );
//  CC := Self.Canvas;
//  CC.Font.Size := OldFontSize;
//  CC.Font.Color := clSilver;
//  CC.TextOut( Trunc( ClientWidth/2 - (Canvas.TextWidth(text1))/2 ), Trunc( ( ClientHeight/2 ) ), text1);
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-14
-------------------------------------------------------------------------------}
procedure TMain.VSTEditing(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex; var Allowed: Boolean);
var
pData : pVTNodeData;
begin
//  if DBTree.AVST.GetNodeLevel( Node ) = 0 then
//    Allowed := false
//  else
//  if DBTree.AVST.GetNodeLevel( Node ) = 1 then
//  begin
//    pData := DBTree.AVST.GetNodeData( Node );
//    if pData^.Bezeichnung.Equals( SC_FAVORITEN ) or pData^.Bezeichnung.Equals( SC_ALLE ) then
//      Allowed := false
//    else
//      Allowed := true;
//  end
//  else
//    Allowed := false;
  pData := DBTree.AVST.GetNodeData( Node );
  if DBTree.AVST.GetNodeLevel( Node ) = 0 then
    Allowed := false
  else
  if not ( pData^.Bezeichnung.Equals( SC_FAVORITEN ) or pData^.Bezeichnung.Equals( SC_ALLE ) ) then
    Allowed := true
  else
    Allowed := false;
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
  pData := DBTree.AVST.GetNodeData( Node );
  //Debug
//  HintText := 'ID: ' + IntToStr( pData^.ID ) + sLineBreak
//              +'Bezeichnung: ' + pData^.Bezeichnung + sLineBreak
//              +'Benutzername: ' +  pData^.Benutzername + sLineBreak
//              +'Passwort: ' +  pData^.Passwort + sLineBreak
//              +'Type: ' +  pData^.Ordner + sLineBreak
//              +'Node-Imageindex: ' + IntToStr (  pData^.NodeImageIdx ) + sLineBreak
//              +'Favorit: ' +  BoolToStr ( pData^.isFavorit, true );
  // Debug - Ende -
  //Installer Beta
  if DBTree.AVST.GetNodeLevel( Node ) = 2 then
  begin
    HintText := 'Bezeichnung: ' + pData^.Bezeichnung + sLineBreak
              +'Benutzername: ' +  pData^.Benutzername + sLineBreak
              +'Passwort: ' +  pData^.Passwort;
  end
  else
    HintText := 'Tipp:' + sLineBreak +
                'Mit Strg + N: können neue Schlüssel erzeugt werden.' + sLineBreak +
                'Außerdem kann man über ein Klick mit der rechten Maustaste viel steuern.';
  //Installer Beta - Ende -
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-06
Change: 2020-09-17 - Favoriten Ordner geschlossen Image hinzugefügt
-------------------------------------------------------------------------------}
procedure TMain.VSTGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean;
  var ImageIndex: TImageIndex);
var
pData, pParentData :pVTNodeData;
begin
  //TODO:Wenn es geht ein paar Sachen auslagern
  pData := DBTree.AVST.GetNodeData( Node );
  if kind in [ikNormal,ikSelected] then
  begin
    if {VST.HasChildren[Node]}DBTree.AVST.GetNodeLevel( Node ) <= 1 then
    begin
      if VST.HasChildren[Node] then
      begin
        if VST.Expanded[Node] then
          ImageIndex := IC_FOLDER_OPEN
        else
        begin
          if pData.Bezeichnung.Equals( SC_FAVORITEN ) then
            ImageIndex := IC_FAV_FOLDER_CLOSE
          else
            ImageIndex := IC_FOLDER_CLOSE;
        end;
      end
      else
        ImageIndex := IC_FOLDER_OPEN;
    end
    else
    begin
      //Abfrage ob der Eltern Node Favoriten heißt
      pParentData := DBTree.AVST.GetNodeData( Node.Parent );
      if pParentData.Bezeichnung.Equals( SC_FAVORITEN ) then
        ImageIndex := IC_FAVORIT
      else
      begin
        case Kind of
          ikNormal : ImageIndex := IC_KEY;
          ikSelected : ImageIndex := IC_KEY_SEL;
        end
      end;
    end;
    pData^.NodeImageIdx := ImageIndex;
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
  if TextType = ttNormal then
  begin
    pData := DBTree.AVST.GetNodeData( Node );
    if pData^.Bezeichnung.Equals( SC_BEZEICHNUNG ) then
      CellText := '*Neuer Schlüssel'
    else
      CellText := pData^.Bezeichnung;
  end;

  if TextType = ttStatic then
  begin
    if DBTree.AVST.GetNodeLevel( Node ) = 0 then // nur root
    begin
      if ClientDataSet1.RecordCount = 0 then
        CellText := ''
      else
        CellText := '[' + IntToStr( ClientDataSet1.RecordCount ) + ']';
    end
    else
    if DBTree.AVST.GetNodeLevel( Node ) = 1 then // nur Ordner
    begin
      if Node.ChildCount = 0 then
        CellText := ''
      else
        CellText := CellText + '[' + IntToStr( Node.ChildCount ) + ']';
    end;
  end;
end;

procedure TMain.VSTKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
//if ( Key = 78 ) and ( Shift = [ssCtrl] ) then  // Strg + N
//  begin
//      AddNewKii;
//  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-18
-------------------------------------------------------------------------------}
procedure TMain.VSTNewText(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex; NewText: string);
var
pData : pVTNodeData;
begin
  pData := DBTree.AVST.GetNodeData( Node );
  pData^.Bezeichnung := NewText;
  UpdateChildrenByEntry;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-17
-------------------------------------------------------------------------------}
procedure TMain.VSTNodeClick(Sender: TBaseVirtualTree; const HitInfo: THitInfo);
var
pData : pVTNodeData;
begin
  if DBTree.AVST.GetNodeLevel( HitInfo.HitNode ) <= 1 then
  Begin
    EnableDBFields( false );
  End
  else
  begin
    pData := DBTree.AVST.GetNodeData( HitInfo.HitNode );
    if ClientDataSet1.Locate( 'ID', pData^.ID , [] ) then
      EnableDBFields( true );
  end;
end;

procedure TMain.VSTPaintText(Sender: TBaseVirtualTree;
  const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType);
begin

end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-11
-------------------------------------------------------------------------------}
procedure TMain.ZuFavoritenhinzufgen1Click(Sender: TObject);
var
pNode : PVirtualNode;
begin
  if DBTree.AVST.Focused then
  begin
    pNode := DBTree.AVST.FocusedNode;
    if not DBTree.IsParentFavFolder( pNode ) then
      DBTree.MoveNodeToFav( pNode )
    else
      DBTree.MoveNodeTo( pNode, SC_ALLE );
      //TODO: Aktualisieren des Node nachdem verschieben
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-10
-------------------------------------------------------------------------------}
procedure TMain.ZwischenablageTimerTimer(Sender: TObject);
begin
  {$IFNDEF TESTLOGIN}
  if ZwischenablageTimer.Enabled then
    Clipboard.Clear;
  {$ENDIF}
end;


end.

