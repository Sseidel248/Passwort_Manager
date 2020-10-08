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
  System.ImageList, Vcl.ImgList, System.Hash, GradientPanel, WinAPI.ActiveX, System.UITypes;

type
  TMainStates = Set of (
    msChanged                  //wenn gesetzt, dann hat sich etwas im Bäumchen geändert
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
    PopupMenu1: TPopupMenu;
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
    GradientPanel1: TGradientPanel;
    SBPasswoerter: TSpeedButton;
    SBEinstellungen: TSpeedButton;
    SBPasswortCheck: TSpeedButton;
    GBDarstellung: TGroupBox;
    GBAllgemein: TGroupBox;
    GBSicherheit: TGroupBox;
    RGSchriftgreosse: TRadioGroup;
    GBFarbverlauf: TGroupBox;
    LFarbeVon: TLabel;
    LFarbeNach: TLabel;
    CBFarbeVon: TComboBox;
    CBFarbeNach: TComboBox;
    CBAutoSave: TCheckBox;
    CBZeitImSpeicher: TComboBox;
    LZeitSpeicherErkl: TLabel;
    BMasterPWChange: TButton;
    BErzeugeTAN: TButton;
    GBInfo: TGroupBox;
    LBtnErkl: TLabel;
    SBAbout: TSpeedButton;
    RGSymbole: TRadioGroup;
    ILklein: TImageList;
    ILGross: TImageList;
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
    procedure PopupMenu1Popup(Sender: TObject);
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
    procedure SuchenEditExit(Sender: TObject);
    procedure SuchenEditClick(Sender: TObject);
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
  private
//    FFonts : TFonts;
    DBTree : TDBTree;
    FMainStates : TMainStates;
    FBezeichnungOld,
    FBenutzerOld,
    FPasswortOld,
    FURLOld,
    FInfoOld : String;
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
    { Private-Deklarationen }
  public
    function GetMaxID : Integer;
    procedure DoChangeStates( Enter : TMainStates; Leave : TMainStates = [] );
    property MainStates : TMainStates read FMainStates write FMainStates;
    { Public-Deklarationen }
  end;

var
  Main: TMain;
  XMLFile : String;

const
  PM_PW = 'pW!M3Pw1gH,A!<3D';

implementation
{$R *.dfm}
uses
  ZipForge, Login_PWM, Global_PWM, Hash_Functions;

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
  FStandartColor := clGrayText;
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
Author: Seidel 2020-10-03
-------------------------------------------------------------------------------}
procedure TMain.UpdateEntryByNode;
var
pNode : PVirtualNode;
{pData,}
pParentData : pVTNodeData;
begin
  pNode := DBTree.AVST.FocusedNode;
//  pData := DBTree.AVST.GetNodeData( pNode );
  pParentData := DBTree.AVST.GetNodeData( pNode.Parent );

  ClientDataSet1.Edit;

  ClientDataSet1isFavorit.AsBoolean := pParentData^.Bezeichnung.Equals( SC_FAVORITEN );

  ClientDataSet1Ordner.AsString := pParentData^.Bezeichnung;

  DoChangeStates( [msChanged] );

  DBTree.AVST.Repaint;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-16
-------------------------------------------------------------------------------}
procedure TMain.UpdateNodeByEntry( Sender : TObject );
var
pNode : PVirtualNode;
pData : pVTNodeData;
begin
  pNode := DBTree.AVST.FocusedNode;
  pData := DBTree.AVST.GetNodeData( pNode );

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

  DoChangeStates( [msChanged] );

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
begin
  //Ort der Gespeicherten und verschlüsselten Datei
//  ArchivPath := ExtractFileDir( ParamStr(0) ) + '\PM_DB\';
  ArchivPath := UserData.PersonalUserSavePath;
  // Create an instance of the TZipForge class
  archiver := TZipForge.Create(nil);
  //erzeugt den Stream aus dem die DB aufgebaut wird
  stream := TMemoryStream.Create;
  with archiver do
  begin
    // Set the name of the archive file we want to create
    //TODO: später soll abhängig vom User die jeweilige KTP Datei genommen werden
    FileName := ArchivPath + ArchivFileName;

    OpenArchive(fmOpenReadWrite);
    // Set base (default) directory for all archive operations
    BaseDir := ExtractFileDir( ParamStr(0) ) + '\PM_DB\';
    // Set encryption algorithm and password
    EncryptionMethod := caAES_256;
//    Password := TLogin.MD5String( PM_PW ); //Change 2020.09.28
//    Password := SHA256String( PM_PW ); //Change 2020.10.03
    Password := AnsiString( GetCryptStr( PM_PW, UserData.User, UserData.PW_Str ) );
    // by specifying its absolute path
    if FindFirst('*.xml', archivItem, faAnyFile-faDirectory) then
    begin
      stream.Clear;
      stream.Position := 0;
      ExtractToStream( archivItem.FileName, stream );
      stream.Position := 0;
      ClientDataSet1.LoadFromStream( stream );
    end;
    CloseArchive();
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

  if msChanged in MainStates then
  begin
    Main.Caption := '*KiiTree von ' + UserData.User;
    SaveDataBtn.Enabled := true;
  end
  else
  begin
    Main.Caption := 'KiiTree von ' + UserData.User;
    SaveDataBtn.Enabled := false;
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
procedure TMain.SaveKTP;
var
  archiver : TZipForge;
//  ArchivFile : String;
  FileForArchiv : String;
  IniForArchiv : String;
  SavePath : String;
//  FileToSave : String;
  stream : TMemoryStream;
  IniList : TStringlist;
begin
  //stream erzeugen worin der CDS gespeichert wird
  stream := TMemoryStream.Create;
  stream.Clear;
  stream.Position := 0;
  ClientDataSet1.SaveToStream( stream );
  stream.Position := 0;

  //erzeugen des Speicherpfades (dieser ist abhängig vvon der .Exe)
//  SavePath := ExtractFileDir( ParamStr(0) ) + '\PM_DB\' ;
//  SavePath := UserData.AppSavePath;
  SavePath := UserData.PersonalUserSavePath;
  if not DirectoryExists( SavePath ) then
    ForceDirectories( SavePath );

  FileForArchiv := 'PMTable.xml';
  IniForArchiv := 'PM.ini';
  // erzeugen der IniStringlist
  iniList := TStringList.Create;
  try
    iniList.Values[SC_USER] := UserData.User;
    IniList.Values[SC_PW] := UserData.PW_Str;
    IniList.Values[SC_KTP] := UserData.KTP_Name_MD5;
    //ini-ende

    // Create an instance of the TZipForge class
    archiver := TZipForge.Create(nil);
    with archiver do
    begin
      // Name des Archives was wir erstellen wollen
      FileName := SavePath + UserData.KTP_Name_MD5;
      // Because we create a new archive,
      // we set Mode to fmCreate
      OpenArchive(fmCreate);
      // Setzen des Verzeichnisses in dem das Archiv platziert wird
      BaseDir := SavePath;
      // Set encryption algorithm and password
      EncryptionMethod := caAES_256;
//      Password :=  TLogin.MD5String( PM_PW ); //Change 2020.09.28
//      Password :=  SHA256String( PM_PW );
      Password := AnsiString( GetCryptStr( PM_PW, UserData.User, UserData.PW_Str ) );
      //hinzufügen einer Datei
      AddFromStream( FileForArchiv, stream );
      AddFromString( IniForArchiv, IniList.Text );

      //AddFiles( FileForArchiv );
      ShowMessage( FileForArchiv + ' und ' + IniForArchiv + ' wurde in ' + FileName + ' gepackt' );
      CloseArchive();
    end;
  finally
    IniList.Free;
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
//    //TODO: Name des Archives später als Kombi aus Username und irgendwas
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
  ClientDataSet1.AggregatesActive := true;
  try
    Result := ClientDataSet1.Aggregates[0].Value;
  finally
    ClientDataSet1.AggregatesActive := false;
  end;
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
      ClientDataSet1.Locate('ID', pDataChild^.ID, [] );     //sucht den passenden Datensatz
      ClientDataSet1.Edit;                                  //stellt die DB auf editieren
      ClientDataSet1Ordner.AsString := pData^.Bezeichnung;  //und benennt sie hier neu
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
    LFarbeVon.Font.Size := size;
    LFarbeNach.Font.Size := size;
    CBFarbeVon.Font.Size := size;
    CBFarbeNach.Font.Size := size;
    RGSymbole.Font.Size := size;
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
    Main.Refresh;
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
        DBTree.AVST.Images := ILGross;
        for Node in Nodes do
        begin
          DBTree.AVST.NodeHeight[ Node ] := 36;
        end;
      end;
      1: begin
        DBTree.AVST.Images := ILNormal;
        for Node in Nodes do
        begin
          DBTree.AVST.NodeHeight[ Node ] := 26;
        end;
      end;
      2: begin
        DBTree.AVST.Images := ILklein;
        for Node in Nodes do
        begin
          DBTree.AVST.NodeHeight[ Node ] := 18;
        end;
      end;
    end;
    //TODO: VST übernimmt die großen Symbole nicht! nach änderung der NodeHeight
    Main.Refresh;
  finally
    Screen.Cursor := crDefault;
  end;
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
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-18
-------------------------------------------------------------------------------}
procedure TMain.AddNewDataSet;
var
pNode, pParentNode : PVirtualNode;
begin
  pParentNode := DBTree.AVST.FocusedNode;

  ClientDataSet1.Append;
  //in den EditierModus Wechseln
  ClientDataSet1.Edit;
  //erzeugt einen neuen DatenSatz
  if DBTree.AVST.GetNodeLevel( pParentNode ) > 0 then
  begin
    pNode := DBTree.AddDBNodeAt( pParentNode );
    if DBTree.IsAddedInFav( pNode ) then
      InitNewData( pNode, true )
    else
      InitNewData( pNode );
  end
  else
  begin
    pNode := DBTree.AddDBNodeAtStandart;
    InitNewData( pNode );
  end;
//  pNode := AddNewDataSet( pParentNode );
  //dient dem zwischenspeichern der DB Einträge
  ClientDataSet1.Next;
  //dem Node seine DB ID geben
  DBTree.SetNodeDBID( pNode, ClientDataSet1ID.AsInteger );
  //aktiviert die Datensatz Felder
  EnableDBFields( true );
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
Author: Seidel 2020-09-18
-------------------------------------------------------------------------------}
procedure TMain.NeuerOrdner1Click(Sender: TObject);
begin
  DBTree.AddDBNodeFolder;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-18
-------------------------------------------------------------------------------}
procedure TMain.NeuerSchlssel1Click(Sender: TObject);
begin
  DoChangeStates( [msChanged] );
  AddNewDataSet;
  EnableDBFields( false );
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-18
-------------------------------------------------------------------------------}
procedure TMain.Ordnerlschen1Click(Sender: TObject);
begin
  DoChangeStates( [msChanged] );
  DBtree.DelFolder;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-18
-------------------------------------------------------------------------------}
procedure TMain.OrdnerUmbenennen1Click(Sender: TObject);
begin
  DoChangeStates( [msChanged] );
  DBTree.RenameDBFolder;
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
Author: Seidel 2020-09-06
-------------------------------------------------------------------------------}
procedure TMain.Button3Click(Sender: TObject);
begin
  PageControl1.ActivePage := PasswortChecker;
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

  if not DBTree.IsAddedInFav( pNode ) then
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
procedure TMain.DBMemoInfoClick(Sender: TObject);
begin
  DBMemoInfo.SelectAll;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-16
-------------------------------------------------------------------------------}
procedure TMain.DBMemoInfoEnter(Sender: TObject);
begin
  FInfoOld := DBMemoInfo.Text;
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
Author: Seidel 2020-09-06
-------------------------------------------------------------------------------}
procedure TMain.EinstellBtnClick(Sender: TObject);
begin
  PageControl1.ActivePage := Options;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-30
-------------------------------------------------------------------------------}
procedure TMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
Text : String;
MResult : Integer;
begin
  if msChanged in MainStates then
  begin
    Text := 'Es sind Änderungen vorhanden.'
    + sLineBreak
    + 'Sollen die Änderungen an Ihrem KiiTree gespeichert werden?';
    MResult := MessageDlg( Text, mtWarning, [mbYes, mbNo], 0, mbYes );
    if MResult = mrYes then
      SaveKTP;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-06
-------------------------------------------------------------------------------}
procedure TMain.FormCreate(Sender: TObject);
//var
//opendialog : TFileOpenDialog;
begin
  Application.HintHidePause := 10000;

  InitInfosHints;

  PageControl1.ActivePage := PW_Manager;

  DBTree := TDBTree.Create( VST );
  DBTree.Create( VST );
  DBTree.FirstOpen;

  Login := TLogin.Create(nil);
  Login.ShowModal;
  XMLFile := UserData.FirstLoadPath + 'EmtyTable.xml';
  if Login.ModalResult = mrCancel then // schließen der kompletten anwendung
    Application.Terminate
  else if Login.ModalResult = mrRetry then //erzeugen einer neuen DB
  begin
    ClientDataSet1.LoadFromFile( XMLFile );
  end
  else if Login.ModalResult = mrOk then//laden einer alten DB
  begin
    ClientDataSet1.LoadFromFile( XMLFile );
    LoadKTP( UserData.KTP_Name_MD5 );
    //soll die Node entsprechend der Datenbank erzeugen
    LoadDBNodeStructur;
    //XMLFile := 'D:\Delphie Embarcadero\Passwort_Manager\DB\PMTable6.xml';
  end;
   EnableDBFields( false );
   LUser.Caption := UserData.User;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-28
-------------------------------------------------------------------------------}
procedure TMain.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if ( Key = 70 ) and ( Shift = [ssCtrl] ) then
  begin
    SuchenEdit.SetFocus;
    SuchenEdit.Clear;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-19
-------------------------------------------------------------------------------}
procedure TMain.FormShow(Sender: TObject);
begin
  //TODO: der Speichername und Ladename soll abhängig von den Anmeldedialog sein
  //hier soll der Anmeldedialog hin!!

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
Author: Seidel 2020-09-18
-------------------------------------------------------------------------------}
procedure TMain.PopupMenu1Popup(Sender: TObject);
var
pNode : PVirtualNode;
begin
  pNode := DBTree.AVST.FocusedNode;
  if not Assigned( pNode ) then
  begin
    NeuerSchlssel1.Enabled          := false;
    NeuerOrdner1.Enabled            := true;
    ZuFavoritenhinzufgen1.Enabled   := false;
    Ordnerlschen1.Enabled           := false;
    Schlssellschen1.Enabled         := false;
    OrdnerUmbenennen1.Enabled       := false;
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

      NeuerSchlssel1.Enabled        := true;
      NeuerOrdner1.Enabled          := true;
      ZuFavoritenhinzufgen1.Enabled := false;
      Schlssellschen1.Enabled       := false;

      NeuerOrdner1.Caption := 'Neuer Ordner';
    end
    //Nodelevel = 2 -> Schlüssel in einem Ordner
    else if DBTree.AVST.GetNodeLevel( pNode ) = 2 then
    begin
      NeuerSchlssel1.Enabled        := false;
      NeuerOrdner1.Enabled          := false;
      ZuFavoritenhinzufgen1.Enabled := true;
      Ordnerlschen1.Enabled         := false;
      Schlssellschen1.Enabled       := true;
      OrdnerUmbenennen1.Enabled       := false;

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

      NeuerOrdner1.Caption := 'Neuer Unterordner';
    end;

  end;
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
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-04
-------------------------------------------------------------------------------}
procedure TMain.RGSymboleClick(Sender: TObject);
begin
  case RGSymbole.ItemIndex of
    0: SetTreeImageListForSize( 0 );
    1: SetTreeImageListForSize( 1 );
    2: SetTreeImageListForSize( 2 );
  end;
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
Author: Seidel 2020-09-30
-------------------------------------------------------------------------------}
procedure TMain.SBEinstellungenClick(Sender: TObject);
begin
  PageControl1.ActivePage := Options;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-30
-------------------------------------------------------------------------------}
procedure TMain.SBPasswoerterClick(Sender: TObject);
begin
  PageControl1.ActivePage := PW_Manager;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-18
-------------------------------------------------------------------------------}
procedure TMain.Schlssellschen1Click(Sender: TObject);
begin
  DoChangeStates( [msChanged] );
  DBTree.DelDBNode;
  EnableDBFields( false );
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
  if SucheText.Equals( 'Suchen' ) or SucheText.Equals( '' ) then
  begin
    DBTree.UnfilterAllTree;
    SuchenEdit.Font.Color := clMedGray;
  end
  else
  begin
    DBTree.FilterTree( SucheText );
    SuchenEdit.Font.Color := clBlack;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-21
-------------------------------------------------------------------------------}
procedure TMain.SuchenEditClick(Sender: TObject);
var
SucheText : String;
begin
  SucheText := SuchenEdit.Text;
  if SucheText.Equals('Suchen') then
  begin
    SuchenEdit.Clear;
  end
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-21
-------------------------------------------------------------------------------}
procedure TMain.SuchenEditExit(Sender: TObject);
var
SucheText : String;
begin
  SucheText := SuchenEdit.Text;
  if SucheText.Equals('') then
  begin
    SuchenEdit.Text := 'Suchen';
  end
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-18
-------------------------------------------------------------------------------}
procedure TMain.VSTDblClick(Sender: TObject);
begin
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
Author: Seidel 2020-09-06
-------------------------------------------------------------------------------}
procedure TMain.VSTGetHint(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex; var LineBreakStyle: TVTTooltipLineBreakStyle;
  var HintText: string);
var
pData : pVTNodeData;
begin
  pData := DBTree.AVST.GetNodeData( Node );
  HintText := 'ID: ' + IntToStr( pData^.ID ) + sLineBreak
              +'Bezeichnung: ' + pData^.Bezeichnung + sLineBreak
              +'Benutzername: ' +  pData^.Benutzername + sLineBreak
              +'Passwort: ' +  pData^.Passwort + sLineBreak
              +'Type: ' +  pData^.Ordner + sLineBreak
              +'Node-Imageindex: ' + IntToStr (  pData^.NodeImageIdx ) + sLineBreak
              +'Favorit: ' +  BoolToStr ( pData^.isFavorit, true );
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
  pData := DBTree.AVST.GetNodeData( Node );
  if pData^.Bezeichnung.Equals(SC_BEZEICHNUNG) then
    CellText := '*Neuer Schlüssel'
  else
    CellText := pData^.Bezeichnung;
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

{------------------------------------------------------------------------------
Author: Seidel 2020-09-18
-------------------------------------------------------------------------------}
end.

