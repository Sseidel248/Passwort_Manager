unit Main_PWM;

{******************************************************************************
Hauptprogramm "KiiTree"
Author: Copyleft 2020 - 2021 Sebastian Seidel

Dient der Erzeugung einer Standalone-Datenbank zur Speicherung der Passw�rter
*******************************************************************************}

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.ShellApi, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.StdCtrls, Vcl.Buttons,
  Vcl.ToolWin, Vcl.ComCtrls, Vcl.ExtCtrls, VirtualTrees, Data.DB,
  Datasnap.DBClient, Vcl.Grids, Vcl.DBGrids, Vcl.Mask, Vcl.DBCtrls, PWM_VST,
  System.ImageList, Vcl.ImgList, System.Hash, GradientPanel, WinAPI.ActiveX, System.UITypes,
  StringGridEx, Vcl.BaseImageCollection, Vcl.ImageCollection,
  Vcl.VirtualImageList, MyGlassButton, System.RegularExpressions, EditEx;

type
  TMainStates = Set of (
    msChanged,                  //wenn gesetzt, dann hat sich etwas im B�umchen ge�ndert oder an den Einstellungen
    msAutoSave,                 //AutoSave aktivieren
    msMPW_Change,               //gerade am �ndern des Masterpasswortes
    msSomethingInClipBrd,       //es wurde etwas von KiiTree in die Zwischenablage gepackt
    msEditAfterNewKiiCreate,    //nachdem ein Kii erzeugt wurde, wird gleich das Editfeld fokosiert
    msHideAsTrayIcon,           //zeigt an das die Anwendung sich in der Taskbar rechts befindet
    msCloseByTray,              //Beenden �ber das Tray Icon
    msShowMinimizeHint,         //soll Hinweise beim minimieren anzeigen
    msMultiSel,                 //mehrfach Auswahl im Kiitree erlauben
    msLoadUserData              //Flag zum markieren dass Userdaten geladen werden
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

type
  TMain = class(TForm)
    Panel2: TPanel;
    LUser: TLabel;
    PageControl1: TPageControl;
    PW_Manager: TTabSheet;
    Options: TTabSheet;
    PasswortChecker: TTabSheet;
    VST: TVirtualStringTree;
    LBezeichnung: TLabel;
    LBenutzername: TLabel;
    LPasswort: TLabel;
    LInfo: TLabel;
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
    GBInfo: TGroupBox;
    LBtnErkl: TLabel;
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
    LCBHinweise: TLabel;
    N5: TMenuItem;
    PasswortinZwischenablage1: TMenuItem;
    BenutzerInZwischenablage1: TMenuItem;
    Einfgen1: TMenuItem;
    PKopieren: TMenuItem;
    CBEditAfterCreateNewKii: TCheckBox;
    SG: TStringGridEx;
    Panel1: TPanel;
    GBPWHinweis: TGroupBox;
    LPWHinweis: TLabel;
    TrayIconKT: TTrayIcon;
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
    SuchenEdit: TEditEx;
    GBToogleHide: TGlassButton;//Change: Seidel 2021-01-28
    VirtualImageList_DBDaten: TVirtualImageList;
    CBMehrfachAuswahl: TCheckBox;
    PopupMenuTrayIcon: TPopupMenu;
    KiitreeOpen: TMenuItem;
    KiitreeEinstellungen: TMenuItem;
    ZwischenspeicherDel: TMenuItem;
    N6: TMenuItem;
    Beenden: TMenuItem;
    VILPopupTrayIcon: TVirtualImageList;
    CBHell: TCheckBox;
    CBDunkel: TCheckBox;
    BDelZwischenspeicher: TButton;
    GBHinweis: TGroupBox;
    BPW_Print: TGlassButton;
    CBShowMessages: TCheckBox;
    GBBeenden: TGlassButton;
    Userdata_List: TTabSheet;
    LBUserdata: TListBox;
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
    procedure PURLimBrowseOerffnenClick(Sender: TObject);
    procedure GBToogleHideClick(Sender: TObject);
    procedure TrayIconKTDblClick(Sender: TObject);
    procedure BeendenClick(Sender: TObject);
    procedure KiitreeOpenClick(Sender: TObject);
    procedure KiitreeEinstellungenClick(Sender: TObject);
    procedure ZwischenspeicherDelClick(Sender: TObject);
    procedure PopupMenuTrayIconPopup(Sender: TObject);
    procedure BDelZwischenspeicherClick(Sender: TObject);
    procedure CBHellClick(Sender: TObject);
    procedure CBDunkelClick(Sender: TObject);
    procedure CBShowMessagesClick(Sender: TObject);
    procedure CBMehrfachAuswahlClick(Sender: TObject);
    procedure GBBeendenClick(Sender: TObject);
    procedure Userdata_ListShow(Sender: TObject);
    procedure CBAutoSaveMouseEnter(Sender: TObject);
    procedure CBAutoSaveMouseLeave(Sender: TObject);
    procedure CBShowMessagesMouseEnter(Sender: TObject);
    procedure CBShowMessagesMouseLeave(Sender: TObject);
    procedure CBEditAfterCreateNewKiiMouseEnter(Sender: TObject);
    procedure CBEditAfterCreateNewKiiMouseLeave(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure DBEditBenutzerMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DBEditPasswortMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DBEditURLMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);

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
    FApp_LoginAbort : Boolean;
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
    procedure ChangeDesignColor( const DesignNr : Integer );
    procedure CheckUserDataLoading;
    { Private-Deklarationen }
  public
    function GetMaxID : Integer;
    procedure DoChangeStates( Enter : TMainStates; Leave : TMainStates = [] );
    procedure AddNewKii;
    procedure AddNewFolder;
    procedure DelKii;
    procedure DelFolder;
    procedure RestoreMain( PageIndex : Integer );
    procedure MinimizeMain;
    procedure InitTrayIcon( const CanSee : Boolean = true );
    property MainStates : TMainStates read FMainStates write FMainStates;

    { Public-Deklarationen }
  end;

var
  Main: TMain;
  PPI_at_start : Integer;//Change: Seidel 2021-01-20

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
  Messages_PWM,
  DnD_TextInOtherApp_PWM;

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

//  function Heller(farbe: TColor; prozent: Byte): TColor;//Change: Seidel 2021-02-03
//  var c: array [0..2] of Word;
//      i: Integer;
//  begin
//   c[0]:= (farbe and $FF);
//   c[1]:= (farbe and $FF00) shr 8;
//   c[2]:= (farbe and $FF0000) shr 16;
//   for i:= 0 to 2 do begin
//    c[i]:= (c[i]* (100 + prozent)) div 100;
//    if c[i]>255 then c[i]:= 255;
//   end;
//   Result:= c[0] + (c[1] shl 8) + (c[2] shl 16);
//  end;

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
Author: Seidel 2021-02-03
-------------------------------------------------------------------------------}
procedure TMain.ChangeDesignColor( const DesignNr : Integer );

  procedure SetForControls( const c1, c2 : TColor );
  begin
    Panel2.Color := c1;
    DBEditBezeichnung.Color := c2;
    DBEditBenutzer.Color := c2;
    DBEditPasswort.Color := c2;
    DBEditURL.Color := c2;
    DBMemoInfo.Color := c2;
    SuchenEdit.Color := c2;
    SG.Color := c2;
    VST.Color := c2;
  end;

var
colorMain,
colorEdits : TColor;
begin
  if DesignNr = 0 then
  begin
    colorMain := clWhite;
    colorEdits := clWhite;
  end
  else
  begin
    colorMain := clMedGray;
    colorEdits := $00E3E2E2;//clWebGainsboro;
  end;

  SetForControls( colorMain, colorEdits );
  CBThemenChange( nil );
end;

{------------------------------------------------------------------------------
Author: Seidel 2021-02-04
-------------------------------------------------------------------------------}
procedure TMain.CheckUserDataLoading;
begin
  if not ( msLoadUserData in MainStates ) then
    DoChangeStates( [msChanged] );
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
      pData^.isFavorit := DBCBFavorit.Checked

    else if (Sender as TComponent).Name = 'ZuFavoritenhinzufgen1' then
    begin
      DBCBFavorit.Checked := DBTree.IsParentFavFolder( pNode );
      ClientDataSet1isFavorit.AsBoolean := DBCBFavorit.Checked;
      pData^.isFavorit := DBCBFavorit.Checked
    end;

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
Author: Seidel 2021-02-09
-------------------------------------------------------------------------------}
procedure TMain.Userdata_ListShow(Sender: TObject);
begin
  {$IFDEF DEBUG}
  LBUserData.Items.Clear;
  LBUserdata.Items.Add( 'User: ' + UserData.User );
  LBUserdata.Items.Add( 'Passwort: ' + UserData.PW_Str );
  LBUserdata.Items.Add( 'Datei: ' + UserData.KTP_Name_MD5 );
  LBUserdata.Items.Add( 'Thema: ' + IntToStr( UserData.UserTheme ) );
  LBUserdata.Items.Add( 'Fontsize: ' + IntToStr( UserData.FontSize ) );
  LBUserdata.Items.Add( 'DesignNr: ' + IntToStr( UserData.DesignNr ) );
  LBUserdata.Items.Add( 'ZeitImSpeicher: ' + IntToStr( UserData.ZeitImSpeicher ) );
  LBUserdata.Items.Add( 'AutoSave: ' + BoolToStr( UserData.AutoSaveChecked, true ) );
  LBUserdata.Items.Add( 'FocusAfterNewKii: ' + BoolToStr( UserData.FocusEditAfterNewKii, true ) );
  LBUserdata.Items.Add( 'MultiSelect: ' + BoolToStr( UserData.MultiSelect, true ) );
  LBUserdata.Items.Add( 'ShowHints: ' +  BoolToStr( UserData.ShowHints, true ) );
  {$ENDIF}
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
  //Ort der Gespeicherten und verschl�sselten Datei
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
      //TODO: sp�ter soll abh�ngig vom User die jeweilige KTP Datei genommen werden
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
          UserData.LoadUserSettings( iniList );
        end;
      end
      else
        UserData.LoadUserSettings();
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

  if msChanged in MainStates then //hat sich etwas ge�ndert
  begin
    if msAutoSave in MainStates then //pr�fe auf Autosave
      SaveKTP
    else
    begin
      Main.Caption := '*KiiTree von ' + UserData.User;
      SBSaveKiiTree.Enabled := true;
    end;
  end
  else
  begin
    Main.Caption := 'KiiTree von ' + UserData.User;
    SBSaveKiiTree.Enabled := false//Change: Seidel 2020-12-25
  end;

  if msSomethingInClipBrd in MainStates then//Change: Seidel 2021-02-03
  begin
    BDelZwischenspeicher.Caption := 'Zwischenspeicher leeren';
    BDelZwischenspeicher.Enabled := true;
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
    DoChangeStates( [msChanged] );//Change: Seidel 2020-11-18 Speichern nachdem man gel�scht hat nicht davor
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
  if DBTree.IsFavFolder( pNode ) or DBtree.IsAllFolder( pNode ) then//Change: Seidel 2021-01-15
  begin
    MessageDelError;
    Exit;
  end;

  if (DBTree.AVST.GetNodeLevel( pNode ) = 1) then
  begin
    DBtree.DelFolder;
    DoChangeStates( [msChanged] );//Change: Seidel 2020-11-18 Speichern nachdem man gel�scht hat nicht davor
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2021-01-29
-------------------------------------------------------------------------------}
procedure TMain.RestoreMain( PageIndex : Integer );
begin
  PageControl1.ActivePageIndex := PageIndex;
  Show;
  WindowState := wsNormal;
  Application.BringToFront;
end;

{------------------------------------------------------------------------------
Author: Seidel 2021-01-30
-------------------------------------------------------------------------------}
procedure TMain.MinimizeMain;
begin
  Hide();
  WindowState := wsMinimized;
end;

{------------------------------------------------------------------------------
Author: Seidel 2021-01-30
-------------------------------------------------------------------------------}
procedure TMain.InitTrayIcon( const CanSee : Boolean = true );
begin
  KiitreeOpen.Visible := CanSee;
  KiitreeEinstellungen.Visible := CanSee;
  ZwischenspeicherDel.Visible := CanSee;
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
Author: Seidel 2021-01-29
-------------------------------------------------------------------------------}
procedure TMain.TrayIconKTDblClick(Sender: TObject);
begin
  RestoreMain( 0 );
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
      OpenDialog.Title := 'W�hlen Sie ihren letzten Speicherpfad';
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

    //erzeugen des Speicherpfades (dieser ist abh�ngig vvon der .Exe)
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
      UserData.AddInKTP( IniList );
      //ini-ende

      // Create an instance of the TZipForge class
      archiver := TZipForge.Create(nil);
      with archiver do
      begin
        // Name des Archives was wir erstellen wollen
        FileName := SavePath + UserData.KTP_Name_MD5;
        // das alte Archiv mit dem alten Masterpasswort wird �berschrieben
        //hat den Vorteil, wenn die KiiTree Datei gel�scht wurde, wird diese trotzdem neu erstellt!! <--!
        try//Change: Seidel 2020-11-29 pr�fen ob ein Speichermedium entfernt wurde
          OpenArchive( fmCreate );
        except
          if MessageDontFindDrive( SavePath ) = mrRetry then//Change: Seidel 2021-02-04
          begin
            SaveKTP;//rekursiver aufruf
            archiver.Free;//verhindert dass das zuvorge�ffnete Archiv offen bleibt
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
        //hinzuf�gen einer Datei
        AddFromStream( KiiTreeForArchiv, stream );
        AddFromString( IniForArchiv, IniList.Text );

        //Testet das erstellte Archiv und repariert es ggf.
        try
          TestFiles( '*.*' );
        except
          RepairArchive;
        end;

        //Speicherdialog {Debug}
        if ( not ( msAutoSave in MainStates ) ) and ( not ( msMPW_Change in MainStates ) ) then
          MessageSaveSuccess( 'Ihr KiiTree wurde erfolgreich gespeichert!' )//Change: Seidel 2021-02-03
        else
        if msMPW_Change in MainStates then
          MessageSaveSuccess( 'Ihr Masterpasswort wurde erfolgreich ge�ndert!' );//Change: Seidel 2021-02-03
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
//  //erzeugen des Speicherpfades (dieser ist abh�ngig vvon der .Exe)
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
//    //hinzuf�gen einer Datei
//    AddFromStream( FileForArchiv, stream);
//    //AddFiles( FileForArchiv );
//    ShowMessage( FileForArchiv + ' wurde in ' + FileName + ' gepackt' );
//    CloseArchive();
//  end;
//
//end;

{------------------------------------------------------------------------------
Author: Seidel 2021-02-04
-------------------------------------------------------------------------------}
procedure TMain.GBBeendenClick(Sender: TObject);
begin
  Close;
end;

{------------------------------------------------------------------------------
Author: Seidel 2021-01-28
-------------------------------------------------------------------------------}
procedure TMain.GBToogleHideClick(Sender: TObject);
var
c : char;
begin
  c := DBEditPasswort.PasswordChar;
  if c = '*' then
  begin
    DBEditPasswort.PasswordChar := #0;
    GBToogleHide.ImageIdx := 1;
    GBToogleHide.Hint := 'Passwort verstecken';//Change: Seidel 2021-03-19
  end
  else
  begin
    DBEditPasswort.PasswordChar := '*';
    GBToogleHide.ImageIdx := 0;
    GBToogleHide.Hint := 'Passwort zeigen';//Change: Seidel 2021-03-19
  end;
end;

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
    //Men�leiste
    LHallo.Font.Size := size;
    SBAbout.Font.Size := size;
    //Einstellungen
    GBDarstellung.Font.Size := size;
    GBAllgemein.Font.Size := size;
    GBSicherheit.Font.Size := size;
    GBFarbverlauf.Font.Size := size;
    GBInfo.Font.Size := size;
    BMasterPWChange.Font.Size := size;
    LBtnErkl.Font.Size := size;
    CBAutoSave.Font.Size := size;
    CBZeitImSpeicher.Font.Size := size;
    LZeitSpeicherErkl.Font.Size := size;
    RGSchriftgreosse.Font.Size := size;
    LCBHinweise.Font.Size := size;
    CBEditAfterCreateNewKii.Font.Size := Size;
    BDelZwischenspeicher.Font.Size := size;
    CBHell.Font.Size := Size;
    CBDunkel.Font.Size := Size;
    CBShowMessages.Font.Size := Size;
    CBMehrfachAuswahl.Font.Size := Size;
    //Passw�rter
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

    //gr��ere
    //Men�leiste
    LUser.Font.Size := size+2;
    SBPasswoerter.Font.Size := size+2;
    SBEinstellungen.Font.Size := size+2;
    SBPasswortCheck.Font.Size := size+2;
    //Passw�rter
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
        DBTree.AVST.DefaultNodeHeight := 36;//Change: Seidel 2020-11-26 vergr��ert bei Start die Node Gr��e
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
      Rect2 := SG.CellRect( ACol,ARow );//Change: Seidel 2020-11-19 Besseres Ausf�llen der Zelle

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
        ResultStr := 'M��ig';
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
      Result := 'Qualit�t: Sehr schwach' + sLineBreak + 'Ihr Passwort ist kleiner als 8 Zeichen!'
    else
    if S.Equals('2') then
      Result := 'Qualit�t: Schwach' + sLineBreak + 'Ihr Passwort enth�lt nur Zeichen eines Zeichentyps!'
    else
    if S.Equals('3') then
      Result := 'Qualit�t: M��ig' + sLineBreak + 'Ihr Passwort enth�lt nur Buchstaben!'
    else
    if S.Equals('4') then
      Result := 'Qualit�t: Stark' + sLineBreak + 'Ihr Passwort enth�lt noch keine Sonderzeichen!'
    else
    if S.Equals('5') then
      Result := 'Qualit�t: Sehr stark' + sLineBreak + 'Ihr Passwort enth�lt viele verschiedene Zeichentypen!';
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
    //wenn im g�ltigen Bereich zeige Zelleninhalt als Hint
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
  SBPasswortCheck.Hint := '�berpr�ft Ihre Passw�rter nach ihre der St�rke.';
  CBZeitImSpeicher.Hint := 'Nach Ablauf der Zeit, wird der Zwischenspeicher und das darin enthaltene Passwort geleert.';
  LZeitSpeicherErkl.Hint := 'Nach Ablauf der Zeit, wird der Zwischenspeicher und das darin enthaltene Passwort geleert.';
  SBPasswoerter.Hint := 'Hier sind all Ihre Zugangdaten.';
  SBSaveKiiTree.Hint := 'Speichert den KiiTree ( Strg + S )';
  SBAddNewKii.Hint := 'F�gt einen weiteren Schl�ssel hinzu ( Strg + N )';
  SBDelKii.Hint := 'L�scht einen markierten Kii ( Entf )';
  SBAddNewFolder.Hint := 'F�gt einen weiteren Ordner hinzu ( Strg + Alt + N )';
  SBDelFolder.Hint := 'L�scht einen markierten Ordner ( Strg + Entf )';
  SBAbisZ.Hint := 'Sortiert die Kii`s aufsteigend';
  SBZbisA.Hint := 'Sortiert die Kii`s absteigend';
  SuchenEdit.Hint := 'Tippen Sie den Namen des Schl�ssels ein nachdem Sie suchen m�chten.';
  BPW_Print.Hint := 'Druckt Ihre Passw�rter als Liste im Querformat aus';
  CBEditAfterCreateNewKii.Hint := 'Nachdem Sie ein Kii erstellt haben, werden die Editierfelder fokosiert';

  LBtnErkl.Visible := false;
  LPWHinweis.Caption := 'Mindestens 8 Zeichen' + sLineBreak
                       +'Mindestens eine Zahl enthalten' + sLineBreak
                       +'Gro� und Kleinbuchstaben beinhalten' + sLineBreak
                       +'Mindestens ein Sonderzeichen ( $, %, �, #, +, u.a. ) enthalten';
  LCBHinweise.Caption := '';
  DBEditURL.Hint := 'Klicken und Strg+O um Internetseite zu �ffnen';//Change: Seidel 2021-03-05
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-18
-------------------------------------------------------------------------------}
procedure TMain.AddNewDataSet;
var
pNode, pParentNode : PVirtualNode;
//Data : pVTNodeData;
begin
  //holen das aktuell ausgew�hlten Nodes
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
  //dient dem zwischenspeichern der DB Eintr�ge
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
Author: Seidel 2021-01-29
-------------------------------------------------------------------------------}
procedure TMain.KiitreeEinstellungenClick(Sender: TObject);
begin
  RestoreMain( 1 );
end;

{------------------------------------------------------------------------------
Author: Seidel 2021-01-29
-------------------------------------------------------------------------------}
procedure TMain.KiitreeOpenClick(Sender: TObject);
begin
  RestoreMain( 0 );
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
Author: Seidel 2020-09-06 Test zum hinzuf�gen von Nodes
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
Author: Seidel 2021-02-03
-------------------------------------------------------------------------------}
procedure TMain.BDelZwischenspeicherClick(Sender: TObject);
begin
  if msSomethingInClipBrd in MainStates then
  begin
    DoChangeStates( [], [msSomethingInClipBrd] );
    {$IFNDEF TESTLOGIN}
    Clipboard.Clear;
    {$ENDIF}
    BDelZwischenspeicher.Caption := 'Zwischenspeicher geleert';
    BDelZwischenspeicher.Enabled := false;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-14
-------------------------------------------------------------------------------}
procedure TMain.BeendenClick(Sender: TObject);
begin
  if Main.Visible then//wenn es nicht sichtbar ist dann befindet es sich im Login
  begin
    DoChangeStates( [msCloseByTray] );
    Close;
  end
  else
    Application.Terminate;
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
  LBtnErkl.Caption := 'Erzeugen einer Sicherheits-TAN' + sLineBreak + sLineBreak + 'Mit jeder dieser TAN Nummern k�nnen Sie sich'
  + ' einmalig anmelden, falls Sie ihr Masterpasswort verlegt oder vergessen haben sollten. Das Masterpasswort sollte'
  + ' danach vorsichtshalber gewechselt werden.';
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-**
-------------------------------------------------------------------------------}
procedure TMain.BMasterPWChangeClick(Sender: TObject);
begin
  MasterPasswortChange := TMasterPasswortChange.Create( Main );
  try
    DoChangeStates( [msMPW_Change] );

    ZwischenablageTimer.Enabled := false;
    MasterPasswortChange.ShowModal;
    if MasterPasswortChange.ModalResult = mrOk then
      SaveKTP;
  finally
    DoChangeStates( [], [msMPW_Change, msChanged] );
    ZwischenablageTimer.Enabled := true;
    MasterPasswortChange.Free;
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
  LBtnErkl.Caption := '�nderung des Masterpasswortes' + sLineBreak + sLineBreak + 'F�r den bestm�glichen Schutz'
  + ' �ndern Sie ihr Masterpasswort regelm��ig und lassen Sie es niemals offen am Arbeitsolatz liegen.';
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
      HeaderList.add( '|Hinweis: Bitte die Passw�rter gut aufbewahren und nicht freizug�nglich liegen lassen.                             |');
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
        //Millimeter Ma�stab
        SetMapMode( Canvas.Handle, MM_LOMETRIC );
        Canvas.Font.Size := 5;//5mm
        Canvas.Font.Name := 'Consolas';
        //Blattgr��e in 1/10mm ermitteln
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
      //Liste f�llen
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
  MessageTest( 'CBAutoSave' );

  CheckUserDataLoading;
  UserData.AutoSaveChecked := CBAutoSave.Checked;//Change: Seidel 2021-03-02 Reihenfolge ge�ndert

  if CBAutoSave.Checked then
  begin
    if msChanged in MainStates then//Change: Seidel 2021-02-24 wenn �nderungen vorhanden sind
      SBSaveKiiTreeClick( Sender );//dann wird es gespeichert bevor Auto-Save aktiviert wird
    DoChangeStates( [msAutoSave] )
  end
  else
    DoChangeStates( [], [msAutoSave] );
end;

{------------------------------------------------------------------------------
Author: Seidel 2021-02-10
-------------------------------------------------------------------------------}
procedure TMain.CBAutoSaveMouseEnter(Sender: TObject);
begin
   LCBHinweise.Caption := 'Automatisiertes Speichern' + sLineBreak + sLineBreak
   + 'Alle �nderungen an ihren KiiTree und den Einstellungen werden sofort gespeichert! Dadurch wird das Speichersymbol in der oberen Men�leiste deaktiviert.';
end;

{------------------------------------------------------------------------------
Author: Seidel 2021-02-10
-------------------------------------------------------------------------------}
procedure TMain.CBAutoSaveMouseLeave(Sender: TObject);
begin
  LCBHinweise.Caption := '';
end;


{------------------------------------------------------------------------------
Author: Seidel 2021-02-10
-------------------------------------------------------------------------------}
procedure TMain.CBDunkelClick(Sender: TObject);
begin
//  MessageTest( 'CBDunkel' );

  CheckUserDataLoading;

  CBHell.Checked := not CBDunkel.Checked;
  if CBDunkel.Checked then
  begin
    UserData.DesignNr := 1;
    ChangeDesignColor( UserData.DesignNr );
  end
  else
    UserData.DesignNr := 0;
end;

{------------------------------------------------------------------------------
Author: Seidel 2021-02-03
-------------------------------------------------------------------------------}
procedure TMain.CBHellClick(Sender: TObject);
begin
//  MessageTest( 'CBHell' );
  CheckUserDataLoading;

  CBDunkel.Checked := not CBHell.Checked;
  if CBHell.Checked then
  begin
    UserData.DesignNr := 0;
    ChangeDesignColor( UserData.DesignNr );
  end
  else
    UserData.DesignNr := 1;
end;

{------------------------------------------------------------------------------
Author: Seidel 2021-02-03
-------------------------------------------------------------------------------}
procedure TMain.CBMehrfachAuswahlClick(Sender: TObject);
begin
  MessageTest( 'CBMehrfachAuswahl' );
  CheckUserDataLoading;

  UserData.MultiSelect := CBMehrfachAuswahl.Checked;//Change: Seidel 2021-03-02 Reihenfolge ge�ndert

  if CBMehrfachAuswahl.Checked then//Change: Seidel 2021-02-03
    DoChangeStates( [msMultiSel] )
  else
    DoChangeStates( [], [msMultiSel] );
end;

{------------------------------------------------------------------------------
Author: Seidel 2021-02-03
-------------------------------------------------------------------------------}
procedure TMain.CBShowMessagesClick(Sender: TObject);
begin
  MessageTest( 'CBShowMessages' );
  CheckUserDataLoading;

  if CBShowMessages.Checked then//Change: Seidel 2021-02-03
    DoChangeStates( [msShowMinimizeHint] )
  else
    DoChangeStates( [], [msShowMinimizeHint] );

  UserData.ShowHints := CBShowMessages.Checked;
end;

{------------------------------------------------------------------------------
Author: Seidel 2021-02-10
-------------------------------------------------------------------------------}
procedure TMain.CBShowMessagesMouseEnter(Sender: TObject);
begin
  LCBHinweise.Caption := 'Benachrichtigung anzeigen' + sLineBreak + sLineBreak
  + 'Durch Aktivierung wird eine Benachrichtigung angezeigt, wo sich die minimierte Anwendnung'
  + ' befindet und welche Funktionen das Taskleistensymbol noch hat.';
end;

{------------------------------------------------------------------------------
Author: Seidel 2021-02-10
-------------------------------------------------------------------------------}
procedure TMain.CBShowMessagesMouseLeave(Sender: TObject);
begin
  LCBHinweise.Caption := '';
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-15
-------------------------------------------------------------------------------}
procedure TMain.CBThemenChange(Sender: TObject);
var
 TeamOrange,
 grau_50P,
 TeamRot,
 DesignColor : TColor;
begin
 TeamOrange := $006bff;
 grau_50P   := clMedGray;//$7F7F7F;
 TeamRot    := RGB( 229, 50, 18 );
 DesignColor:= Panel2.Color;//Change: Seidel 2021-02-03
  case CBThemen.ItemIndex of
    0: SetThemeColor( clGreen, clMoneyGreen, DesignColor );
    1: SetThemeColor( clWebGoldenRod, clWebMoccasin, DesignColor );
    2: SetThemeColor( clWebOrangeRed, {clWebYellow}$0000A5FF, DesignColor );
    3: SetThemeColor( clWebRoyalBlue, clWebSkyBlue, DesignColor );
    4: SetThemeColor( TeamOrange, TeamOrange, grau_50P );//Change: Seidel 2021-01-12 TeamOrange Design
    5: SetThemeColor( TeamRot, TeamRot, grau_50P );//Change: Seidel 2021-01-12 Team Rot Design
  end;
  //TODO: implmentieren
//  if not (Sender = nil) then
//    UserData.SetUserTheme( IntToStr( CBThemen.ItemIndex ) );
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-28
-------------------------------------------------------------------------------}
procedure TMain.CBEditAfterCreateNewKiiClick(Sender: TObject);
begin
  MessageTest( 'EditAfterCreateNewKii' );

  CheckUserDataLoading;

  UserData.FocusEditAfterNewKii := CBEditAfterCreateNewKii.Checked;
  if CBEditAfterCreateNewKii.Checked then
    DoChangeStates( [msEditAfterNewKiiCreate] )
  else
    DoChangeStates( [], [msEditAfterNewKiiCreate] );
end;

{------------------------------------------------------------------------------
Author: Seidel 2021-02-10
-------------------------------------------------------------------------------}
procedure TMain.CBEditAfterCreateNewKiiMouseEnter(Sender: TObject);
begin
  LCBHinweise.Caption := 'Direkte Bearbeitung' + sLineBreak + sLineBreak
  + 'Durch Aktivierung springt der Focus nach dem Erzeugen eines neues Kiis in das Dateneingabefeld,'
  + ' wodurch mit die Eingabe begonnen werden kann.';
end;

{------------------------------------------------------------------------------
Author: Seidel 2021-02-10
-------------------------------------------------------------------------------}
procedure TMain.CBEditAfterCreateNewKiiMouseLeave(Sender: TObject);
begin
  LCBHinweise.Caption := '';
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
  UserData.ZeitImSpeicher := CBZeitImSpeicher.ItemIndex;
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
  //f�ngt eine Exception beim Start ab
  if not Assigned( DBTree ) then
    Exit;
  //f�ngt einen Node ab der Nil ist
  pNode := DBTree.AVST.FocusedNode;
  if not Assigned( pNode ) then
    Exit;
  //f�ngt einen Verschieben eines Ordner ab
  if DBTree.AVST.GetNodeLevel( pNode ) <= 1 then
    Exit;
  //f�ngt andere Mausklicks ab//Change: Seidel 2021-01-20
  if ( Button = mbRight ) or ( Button = mbMiddle ) then
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
Author: Seidel 2021-03-20
-------------------------------------------------------------------------------}
procedure TMain.DBEditBenutzerMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  CheckAndExecute( DBEditBenutzer.Text, Shift, Sender );
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
Author: Seidel 2021-03-20
-------------------------------------------------------------------------------}
procedure TMain.DBEditPasswortMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  CheckAndExecute( DBEditPasswort.Text, Shift, Sender );
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
Author: Seidel 2021-03-20
-------------------------------------------------------------------------------}
procedure TMain.DBEditURLMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  CheckAndExecute( DBEditURL.Text, Shift, Sender );
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
Author: Seidel 2020-12-29//Change: Seidel 2021-01-04 Skalierung der Button wurde gefixxt
-------------------------------------------------------------------------------}
//procedure TMain.FormAfterMonitorDpiChanged(Sender: TObject; OldDPI,
//  NewDPI: Integer);
//
//  procedure ScaleBtnFont( Btn : TGlassButton; NewDPI, OldDPI : Integer );
//  var
//  Faktor : Double;
//  begin
//    //TODO; Skalierungsfehler hier oder dierekt im GlassButton
//
//    Faktor := NewDPI / 96;  //96 = 100%
//    if NewDPI > OldDPI then
//      Btn.Font.Size := Round( SBAbout.Font.Size * Faktor)
//    else if NewDPI < OldDPI then
//      Btn.Font.Size := Round( SBAbout.Font.Size / Faktor);
//    Btn.Refresh;
//  end;

//begin
//  ScaleBtnFont( SBAbout, NewDPI, OldDPI );
//  ScaleBtnFont( SBPasswoerter, NewDPI, OldDPI );
//  ScaleBtnFont( SBPasswortCheck, NewDPI, OldDPI );
//  ScaleBtnFont( SBEinstellungen, NewDPI, OldDPI );
//end;

{------------------------------------------------------------------------------
Author: Seidel 2020-11-25
-------------------------------------------------------------------------------}
procedure TMain.FormClose(Sender: TObject; var Action: TCloseAction);
var
MResult : Integer;
begin
  if ( msChanged in MainStates ) then
  begin
    if msAutoSave in MainStates then
      MResult := mrYes
    else
      MResult := MessageSave;

    if MResult = mrYes then
      SaveKTP;

    DoChangeStates( [], [msChanged] );
  end;
  MainIni.SaveSetting;
  TrayIconKT.Visible := false;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-11-25
-------------------------------------------------------------------------------}
procedure TMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
MResult : Integer;
begin
  DBTree.AVST.SetFocus;//Change: Seidel 2021-03-19 wechselt des Focus, damit msChanged gesetzt wird
  if msCloseByTray in MainStates then//Change: Seidel 2021-02-03
  begin
    DoChangeStates( [], [msCloseByTray] );
    {$IFNDEF TESTLOGIN}
    Clipboard.Clear;
    {$ENDIF}
    CanClose := true;
    Exit;
  end;

  if msSomethingInClipBrd in MainStates then//Change: Seidel 2021-01-30
    MResult := MessageMinClearOrClose
  else
    MResult := MessageMinOrClose;

  if MResult = mrMini then//Change: Seidel 2021-01-30
  begin
    MinimizeMain;
    CanClose := false;

    if msShowMinimizeHint in MainStates then//Change: Seidel 2021-02-03
      TrayIconKT.ShowBalloonHint;
  end
  else
  if MResult = mrCloseNClear then//Change: Seidel 2021-01-30
  begin
    {$IFNDEF TESTLOGIN}
      Clipboard.Clear;
    {$ENDIF}
    CanClose := true;
  end
  else
  if MResult = mrClose then//Change: Seidel 2021-01-30
    CanClose := true
  else                     //Change: Seidel 2021-01-30
    CanClose := false;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-06
-------------------------------------------------------------------------------}
procedure TMain.FormCreate(Sender: TObject);
begin
  CreateDropTextSource( Self );

  TrayIconKT.Visible := true;
  InitTrayIcon( false );

  Application.HintHidePause := 10000;
  PPI_at_start := GetCurrentPPI;

  {$IFDEF DEBUG}
  DB_Tabelle.TabVisible := true;
  Userdata_List.TabVisible := true;
  CBTestDisableMenuButton.Visible := true;
  CBMehrfachAuswahl.Visible := true;
  {$ENDIF}

  //pr�ft auch ob Schreibrecht vorhanden sind
//  if not MainIni.CreateIfNotExist then
//    Application.Terminate;

  DefaultSettings.Init( handle );

  //setzen der maximalen L�nge
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

  Login := TLogin.Create(Main);
  try
    //Login Formular anzeigen und auf Modalresult warten
    Login.ShowModal;
    if Login.ModalResult = mrCancel then // schlie�en der kompletten anwendung
    begin
      FApp_LoginAbort := true;
      WindowState := wsMinimized;
      Application.Terminate;
    end
    else
    begin
      InitTrayIcon;
      ClientDataSet1.LoadFromFile( DefaultSettings.DefaultDBPath );
      if Login.ModalResult = mrRetry then //erzeugen einer neuen DB ( neuer User )
      begin
        DoChangeStates( [msChanged] );  //Change 2020-10-10 Damit gespeichert werden kann
        UserData.LoadUserSettings();//Change: Seidel 2021-02-10 damit die Standartwert geladen werden
      end
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
Author: Seidel 2021-03-20
-------------------------------------------------------------------------------}
procedure TMain.FormDestroy(Sender: TObject);
begin
  FreeDropTextSource;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-28
-------------------------------------------------------------------------------}
procedure TMain.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
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
Author: Seidel 2021-01-23
-------------------------------------------------------------------------------}
procedure TMain.FormShow(Sender: TObject);
begin
  if not FApp_LoginAbort then
    Main.WindowState := wsNormal;
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
    //Nodelevel = 1 -> Ordner der einzelnen Schl�ssel
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
    //Nodelevel = 2 -> Schl�ssel in einem Ordner
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
      //Ordner hinzuf�gen ist aktiv
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
Author: Seidel 2021-01-30
-------------------------------------------------------------------------------}
procedure TMain.PopupMenuTrayIconPopup(Sender: TObject);
begin
  if msSomethingInClipBrd in MainStates then
  begin
    ZwischenspeicherDel.Caption := 'Zwischenspeicher l�schen';
    ZwischenspeicherDel.Enabled := true;
  end
  else
  begin
    ZwischenspeicherDel.Caption := 'Zwischenspeicher leer';
    ZwischenspeicherDel.Enabled := false;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2021-01-20
-------------------------------------------------------------------------------}
procedure TMain.PURLimBrowseOerffnenClick(Sender: TObject);

  function PrepareStr( const Value : String ): String;//Change: Seidel 2021-01-20
  var
  len : Integer;
  pattern :String;
  begin
    Result := Trim( Value );
    len := Length( Result );
    pattern := '^(https?:\/\/)?(www\.)?';//Change: Seidel 2021-02-24 KT-74

    //alles klein schreiben
    Result := LowerCase( Result );

    // / am Ende h�ngen
    if ( Pos( '/', Result ) = len ) or ( Pos( '\', Result ) = len ) then
      Result := Copy( Result, 1, len-1 );

    //wenn kein "www."; "http://" oder "https://" davor ist dann h�nge "https://" ran
    if not TRegex.IsMatch( Result, pattern ) then
    begin
      Result := Concat( 'https://', Result );
    end;
  end;

var
regex : TRegex;
URLStr : String;
const
pattern = '^(https?:\/\/)?(www\.)?([a-zA-Z0-9]+(-?[a-zA-Z0-9])*\.)+[\w]{2,}(\/\S*)?$';//Change: Seidel 2021-02-24 KT-74
begin
  regex := TRegex.Create( Pattern );
  URLStr := PrepareStr( ClientDataSet1URL.AsString );
  if regex.IsMatch( URLStr ) then
    ShellExecute(Handle, 'open', PWideChar( URLStr ), nil, nil, SW_SHOWNORMAL)
  else
    MessageOpenURLError;
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

      if Caption.Contains( 'Internet' ) then//Change: Seidel 2021-01-20
      begin
        PURLimBrowseOerffnen.Enabled := true;
        PURLimBrowseOerffnen.Visible := true;
      end
      else
      begin
        PURLimBrowseOerffnen.Enabled := false;
        PURLimBrowseOerffnen.Visible := false;
      end;

    end;
  end;

begin
  ChangePopupDaten( DBEditBezeichnung );
  ChangePopupDaten( DBEditBenutzer , 'Benutzername in Zwischenablage kopieren' );
  ChangePopupDaten( DBEditPasswort , 'Passwort in Zwischenablage kopieren' );
  ChangePopupDaten( DBEditURL , 'Internetseite in Zwischenablage kopieren' );
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-10
Change: Seidel 2021-03-01 Strg+Alt+C -> Strg+A
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
//    DBEditBenutzer.SelStart := 0;//Change: Seidel 2021-03-01
  end
  else
  if DBEditPasswort.Focused then
  begin
    DBEditPasswort.SelectAll;
    DBEditPasswort.CopyToClipboard;
//    DBEditPasswort.SelStart := 0;//Change: Seidel 2021-03-01
  end
  else
  if DBEditURL.Focused then
  begin
    DBEditURL.SelectAll;
    DBEditURL.CopyToClipboard;
//    DBEditURL.SelStart := 0;//Change: Seidel 2021-03-01
  end;
  {$ENDIF}
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-04
-------------------------------------------------------------------------------}
procedure TMain.RGSchriftgreosseClick(Sender: TObject);
var
Size : Integer;
begin
  Size := 8;
  case RGSchriftgreosse.ItemIndex of
//    0: SetFontSizes( 12 );
//    1: SetFontSizes( 10 );
//    2: SetFontSizes( 8 );
    0: Size := MulDiv( 12, FCurrentPPI, PPI_at_start );//Change: Seidel 2021-01-20
    1: Size := MulDiv( 10, FCurrentPPI, PPI_at_start );//Change: Seidel 2021-01-20
    2: Size := MulDiv( 8, FCurrentPPI, PPI_at_start );//Change: Seidel 2021-01-20
  end;
  //TODO: implementieren
//  if not (Sender = nil) then//Change: Seidel 2021-01-15
//  begin
//    UserData.SetFontSize( IntToStr( RGSchriftgreosse.ItemIndex ) );
//    SetFontSizes( Size );
//  end;
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

{------------------------------------------------------------------------------
Author: Seidel 2021-02-03
-------------------------------------------------------------------------------}
procedure TMain.SBAboutClick(Sender: TObject);
begin
  About_Dlg := TAbout_Dlg.Create( Main );//Change: Seidel 2021-02-03
  try
    About_Dlg.ShowModal;
  finally
    About_Dlg.Free;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-15
-------------------------------------------------------------------------------}
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
    DoChangeStates( [msChanged] );//Change: Seidel 2020-11-18 Speichern nachdem man gel�scht hat nicht davor
    EnableDBFields( false );
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-21
-------------------------------------------------------------------------------}
procedure TMain.SuchenEditChange(Sender: TObject);
var
SucheText : String;
LastNode : PVirtualNode;
pLastNodeData : pVTNodeData;
begin
  SucheText := SuchenEdit.Text;
  LastNode := nil;
  if SucheText.Equals( '' ) then
  begin
    DBTree.UnfilterAllTree;
  end
  else
  begin
    LastNode := DBTree.FilterTree( SucheText );
    if LastNode <> nil then
    begin
      pLastNodeData := DBTree.AVST.GetNodeData( LastNode );
      if ClientDataSet1.Locate( 'ID', pLastNodeData^.ID , [] ) then
        EnableDBFields( true );
    end;
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
  begin
    if DBTree.AVST.Color = clWhite then//Change: Seidel 2021-02-03
      ItemColor := clCream
    else
      ItemColor := clLtGray;
  end
  else
  begin
    if DBTree.AVST.Color = clWhite then//Change: Seidel 2021-02-03
      ItemColor := clWhite
    else
      ItemColor := clWebGainsboro;
  end;

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
    1: begin
      case Mode of //Change: Seidel 2021-01-15
        dmAbove:    Accept := false;
        dmOnNode:   Accept := true;
        dmBelow:    Accept := false;
      end;
    end;
    2: begin
      case Mode of // DropPosition in NodeAttachMode umsetzen
        dmAbove:    Accept := true;
        dmOnNode:   Accept := false;
        dmBelow:    Accept := true;
      end;
    end;
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
//  �ber eine Ableitung einbauen!! Drawtext()

//  text1 := '<Hallo, das ist ein Test f�r einen Langen Hinweis>';
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
                'Mit Strg + N: k�nnen neue Schl�ssel erzeugt werden.' + sLineBreak +
                'Au�erdem kann man �ber ein Klick mit der rechten Maustaste viel steuern.';
  //Installer Beta - Ende -
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-06
Change: 2020-09-17 - Favoriten Ordner geschlossen Image hinzugef�gt
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
      //Abfrage ob der Eltern Node Favoriten hei�t
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
      CellText := '*Neuer Schl�ssel'
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

    UpdateNodeByEntry( Sender );
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

{------------------------------------------------------------------------------
Author: Seidel 2021-01-30
-------------------------------------------------------------------------------}
procedure TMain.ZwischenspeicherDelClick(Sender: TObject);
begin
  if msSomethingInClipBrd in MainStates then
    DoChangeStates( [], [msSomethingInClipBrd] );
  {$IFNDEF TESTLOGIN}
    Clipboard.Clear;
  {$ENDIF}
end;

end.
