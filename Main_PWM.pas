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
    AddNewDatasetBtn: TButton;
    DelDataSetBtn: TButton;
    ImageList1: TImageList;
    AddNodeTest: TButton;
    PopupMenu1: TPopupMenu;
    NeuerOrdner1: TMenuItem;
    NeuerSchlssel1: TMenuItem;
    N1: TMenuItem;
    ZuFavoritenhinzufgen1: TMenuItem;
    N2: TMenuItem;
    Ordnerlschen1: TMenuItem;
    Schlssellschen1: TMenuItem;
    GroupBox1: TGroupBox;
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
    Label1: TLabel;
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
    procedure DBCheckBox1MouseUp(Sender: TObject; Button: TMouseButton;
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
  private
    AFonts : TFonts;
    DBTree : TDBTree;
    procedure AddNewDataSet;
    procedure InitNewData( pNode : pVirtualNode = nil; AddedInFav : Boolean = false);
    procedure UpdateNodeEntry( Sender : TObject );
    procedure EnableDBFields( enable : Boolean );
    procedure UpdateChildrenEntries;
    procedure LoadPMPK( ArchivFileName : String);
    procedure SavePMPK; overload;
    procedure SavePMPK(FileForArchiv : String); overload;
    procedure LoadDBNodeStructur;
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Main: TMain;
  XMLFile : String;

const
  PM_PW = 'pW!M3Pw1gH,A!<3D';

implementation

uses
  ZipForge, Login_PWM, Global_PWM;

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
Author: Seidel 2020-09-16
-------------------------------------------------------------------------------}
procedure TMain.UpdateNodeEntry( Sender : TObject );
var
pNode : PVirtualNode;
pData : pVTNodeData;
begin
  pNode := DBTree.AVST.FocusedNode;
  pData := DBTree.AVST.GetNodeData( pNode );

  ClientDataSet1.Edit;

  if (Sender as TComponent).Name = 'DBEditBezeichnung' then
  begin
    pData^.Bezeichnung := ClientDataSet1Bezeichnung.AsString;
  end
  else if (Sender as TComponent).Name = 'DBEditBenutzer' then
  begin
    pData^.Benutzername := ClientDataSet1Benutzername.AsString;
  end
  else if (Sender as TComponent).Name = 'DBEditPasswort' then
  begin
    pData^.Passwort := ClientDataSet1Passwort.AsString;
  end
  else if (Sender as TComponent).Name = 'DBMemoInfo' then
  begin
    pData^.Info := ClientDataSet1Info.AsString;
  end
  else if (Sender as TComponent).Name = 'DBCheckBox1' then
  begin
    pData^.isFavorit := DBCheckBox1.Checked;
  end;
  ClientDataSet1NodeImageIndex.AsInteger := pData^.NodeImageIdx;

  DBTree.AVST.Repaint;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-18
-------------------------------------------------------------------------------}
procedure TMain.LoadPMPK( ArchivFileName : String );
var
  archiver : TZipForge;
  ArchivPath : String;
  FileForArchiv : String;
  archivItem : TZFArchiveItem;
  stream : TMemoryStream;
begin
  //Ort der Gespeicherten und verschlüsselten Datei
  ArchivPath := ExtractFileDir( ParamStr(0) ) + '\PM_DB\';
  // Create an instance of the TZipForge class
  archiver := TZipForge.Create(nil);
  //erzeugt den Stream aus dem die DB aufgebaut wird
  stream := TMemoryStream.Create;
  with archiver do
  begin
    // Set the name of the archive file we want to create
    //TODO: später soll abhängig vom User die jeweilige PMPK Datei genommen werden
    FileName := ArchivPath + ArchivFileName;

    OpenArchive(fmOpenReadWrite);
    // Set base (default) directory for all archive operations
    BaseDir := ExtractFileDir( ParamStr(0) ) + '\PM_DB\';
    // Set encryption algorithm and password
    EncryptionMethod := caAES_256;
    Password := TLogin.MD5String( PM_PW );
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
  //TODO: Laden so implementieren das die Nodes erstellt werden
  LoadPMPK('test.PMPK');
  //soll die Node entsprechend der Datenbank erzeugen
  LoadDBNodeStructur;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-19
-------------------------------------------------------------------------------}
procedure TMain.LoadDBNodeStructur;
var
Nodes : TVTVirtualNodeEnumeration;
FolderNameList : TStringList;
  I: Integer;
begin
  Nodes := DBTree.AVST.Nodes();

  //Sammeln aller Ordnernamen in der Datenbank
  FolderNameList := TStringList.Create;
  for I := 0 to ClientDataSet1.RecordCount-1 do
  begin
    ClientDataSet1.Locate( 'ID', I+1, [] );
    FolderNameList.Add( ClientDataSet1Ordner.AsString );
  end;

  DBTree.LoadNodes( Nodes, FolderNameList, ClientDataSet1 );

  DBTree.AVST.FullExpand();
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-18
-------------------------------------------------------------------------------}
procedure TMain.SavePMPK;
var
  archiver : TZipForge;
  ArchivFile : String;
  FileForArchiv : String;
  IniForArchiv : String;
  SavePath : String;
  FileToSave : String;
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
  SavePath := UserData.SavePath;
  if not DirectoryExists( SavePath ) then
    ForceDirectories( SavePath );

  FileForArchiv := 'PMTable.xml';
  IniForArchiv := 'PM.ini';
  // erzeugen der IniStringlist
  iniList := TStringList.Create;
  try
    iniList.Values[SC_USER] := UserData.User;
    IniList.Values[SC_PW] := UserData.PW_Str;
    IniList.Values[SC_PMPK] := UserData.PMPK_Name_MD5;
    //ini-ende

    // Create an instance of the TZipForge class
    archiver := TZipForge.Create(nil);
    with archiver do
    begin
      // Name des Archives was wir erstellen wollen
      //TODO: Name des Archives später als Kombi aus Username und irgendwas
      FileName := SavePath + UserData.PMPK_Name_MD5;
      // Because we create a new archive,
      // we set Mode to fmCreate
      OpenArchive(fmCreate);
      // Setzen des Verzeichnisses in dem das Archiv platziert wird
      BaseDir := SavePath;
      // Set encryption algorithm and password
      EncryptionMethod := caAES_256;
      Password :=  TLogin.MD5String( PM_PW );
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
procedure TMain.SavePMPK(FileForArchiv : String);
var
  archiver : TZipForge;
  ArchivFile : String;
  SavePath : String;
  FileToSave : String;
  stream : TMemoryStream;
begin
  //stream erzeugen worin der CDS gespeichert wird
  stream := TMemoryStream.Create;
  stream.Clear;
  stream.Position := 0;
  ClientDataSet1.SaveToStream( stream );
  stream.Position := 0;

  //erzeugen des Speicherpfades (dieser ist abhängig vvon der .Exe)
  SavePath := ExtractFileDir( ParamStr(0) ) + '\PM_DB\' ;
  if not DirectoryExists( SavePath ) then
    ForceDirectories( SavePath );

  // Create an instance of the TZipForge class
  archiver := TZipForge.Create(nil);
  with archiver do
  begin
    // Name des Archives was wir erstellen wollen
    //TODO: Name des Archives später als Kombi aus Username und irgendwas
    FileName := SavePath + 'test.PMPK';
    // Because we create a new archive,
    // we set Mode to fmCreate
    OpenArchive(fmOpenReadWrite);
    // Setzen des Verzeichnisses in dem das Archiv platziert wird
    BaseDir := SavePath;
    // Set encryption algorithm and password
    EncryptionMethod := caAES_256;
    Password :=  TLogin.MD5String( PM_PW );
    //hinzufügen einer Datei
    AddFromStream( FileForArchiv, stream);
    //AddFiles( FileForArchiv );
    ShowMessage( FileForArchiv + ' wurde in ' + FileName + ' gepackt' );
    CloseArchive();
  end;

end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-18
-------------------------------------------------------------------------------}
procedure TMain.saveTestClick(Sender: TObject);
begin
  SavePMPK;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-18
-------------------------------------------------------------------------------}
procedure TMain.UpdateChildrenEntries;
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
  DBCheckBox1.Enabled := enable;
  DBEditURL.Enabled := enable;
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

  ClientDataSet1Bezeichnung.AsString := 'Bezeichnung eingeben...' ;
  ClientDataSet1Benutzername.AsString := 'Benutzername eingeben...';
  ClientDataSet1Passwort.AsString := 'Passwort eingeben...';
  ClientDataSet1Info.AsString := 'Ihre Notiz';
  ClientDataSet1isFavorit.AsBoolean := AddedInFav;
  DBCheckBox1.Checked := AddedInFav;

  pNodeData := DBTree.AVST.GetNodeData( pNode );
  if Assigned(pNodeData) then
  begin
    ParentData := DBTree.AVST.GetNodeData( pNode.Parent );

    pNodeData.Bezeichnung := ClientDataSet1Bezeichnung.AsString;
    pNodeData.Benutzername := ClientDataSet1Benutzername.AsString;
    pNodeData.Passwort := ClientDataSet1Passwort.AsString;
    pNodeData.Info := ClientDataSet1Info.AsString;
    pNodeData.isFavorit := ClientDataSet1isFavorit.AsBoolean;

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
  AddNewDataSet;
  EnableDBFields( false );
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-18
-------------------------------------------------------------------------------}
procedure TMain.Ordnerlschen1Click(Sender: TObject);
begin
  DBtree.DelFolder;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-18
-------------------------------------------------------------------------------}
procedure TMain.OrdnerUmbenennen1Click(Sender: TObject);
begin
  DBTree.RenameDBFolder;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-06
-------------------------------------------------------------------------------}
procedure TMain.AddFolderBtnClick(Sender: TObject);
begin
  DBTree.AddDBNodeFolder;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-06
-------------------------------------------------------------------------------}
procedure TMain.AddNewDatasetBtnClick(Sender: TObject);
begin
  AddNewDataSet;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-06
-------------------------------------------------------------------------------}
procedure TMain.DelDataSetBtnClick(Sender: TObject);
begin
  DBTree.DelDBNode;
  EnableDBFields( false );
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-18
-------------------------------------------------------------------------------}
procedure TMain.DelFolderBtnClick(Sender: TObject);
begin
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
  PageControl1.ActivePage := TabSheet3;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-17
-------------------------------------------------------------------------------}
procedure TMain.DBCheckBox1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
pNode, pNodeFav : PVirtualNode;
pData, pDataFav : pVTNodeData;
Nodes :TVTVirtualNodeEnumeration;
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

  DBTree.MoveNodeToFav( pNode );

  UpdateNodeEntry( Sender );
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
procedure TMain.DBEditBenutzerExit(Sender: TObject);
begin
  UpdateNodeEntry( Sender );
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
  end;
  DBTree.AVST.Refresh;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-16
-------------------------------------------------------------------------------}
procedure TMain.DBEditBezeichnungDblClick(Sender: TObject);
begin
  DBEditBezeichnung.SelectAll;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-16
-------------------------------------------------------------------------------}
procedure TMain.DBEditBezeichnungExit(Sender: TObject);
begin
  UpdateNodeEntry( Sender );

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
  end;
  DBTree.AVST.Refresh;
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
procedure TMain.DBEditPasswortExit(Sender: TObject);
begin
  UpdateNodeEntry( Sender );
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
  end;
  DBTree.AVST.Refresh;
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
procedure TMain.DBEditURLExit(Sender: TObject);
begin
  UpdateNodeEntry( Sender );
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
procedure TMain.DBMemoInfoExit(Sender: TObject);
begin
  UpdateNodeEntry( Sender );
  DBTree.AVST.Refresh;
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
var
opendialog : TFileOpenDialog;
begin
  Application.HintHidePause := 10000;

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
    LoadPMPK( UserData.PMPK_Name_MD5 );
    //soll die Node entsprechend der Datenbank erzeugen
    LoadDBNodeStructur;
    //XMLFile := 'D:\Delphie Embarcadero\Passwort_Manager\DB\PMTable6.xml';
  end;
   EnableDBFields( false );
   LUser.Caption := UserData.User;
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
Author: Seidel 2020-09-06
-------------------------------------------------------------------------------}
procedure TMain.SaveDataBtnClick(Sender: TObject);
begin
  SavePMPK;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-18
-------------------------------------------------------------------------------}
procedure TMain.Schlssellschen1Click(Sender: TObject);
begin
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
              +'Ordner: ' +  pData^.Ordner + sLineBreak
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
          if pData.Bezeichnung.Equals('Favoriten') then
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
      if pParentData.Bezeichnung.Equals('Favoriten') then
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
  if pData^.Bezeichnung.Equals('Bezeichnung eingeben...') then
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
  UpdateChildrenEntries;
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
    EnableDBFields( true );
    pData := DBTree.AVST.GetNodeData( HitInfo.HitNode );
    ClientDataSet1.Locate( 'ID', pData^.ID , [] );
  end;

end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-18
-------------------------------------------------------------------------------}
end.
