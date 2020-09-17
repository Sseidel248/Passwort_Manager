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
    procedure HidePWBtnClick(Sender: TObject);
    procedure SeePWBtnClick(Sender: TObject);
    procedure DBMemoInfoClick(Sender: TObject);
    procedure DBEditBezeichnungExit(Sender: TObject);
    procedure DBEditBezeichnungClick(Sender: TObject);
    procedure DBEditBenutzerClick(Sender: TObject);
    procedure DBEditPasswortClick(Sender: TObject);
    procedure DBEditBenutzerExit(Sender: TObject);
    procedure DBEditPasswortExit(Sender: TObject);
    procedure DBMemoInfoExit(Sender: TObject);
    procedure DBCheckBox1Click(Sender: TObject);
  private
    AFonts : TFonts;
    DBTree : TDBTree;
    procedure InitNewData( pNode : pVirtualNode = nil);
    procedure UpdateNodeEntry( Sender : TObject );
    procedure EnableDBFields( enable : Boolean );
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Main: TMain;
  XMLFile : String;

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
Author: Seidel 2020-09-16
-------------------------------------------------------------------------------}
procedure TMain.UpdateNodeEntry( Sender : TObject );
var
pNode : PVirtualNode;
pData : pVTNodeData;
begin
  pNode := DBTree.AVST.FocusedNode;
  pData := DBTree.AVST.GetNodeData( pNode );

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

  DBTree.AVST.Repaint;
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
end;
{------------------------------------------------------------------------------
Author: Seidel 2020-09-06
Change: 2020-09-16
-------------------------------------------------------------------------------}
procedure TMain.InitNewData( pNode : pVirtualNode = nil);
var
ParentData, pNodeData : pVTNodeData;
begin

  ClientDataSet1ID.Value := ClientDataSet1.IndexFieldCount;
  ClientDataSet1Bezeichnung.AsString := 'Bezeichnung eingeben...' ;
  ClientDataSet1Benutzername.AsString := 'Benutzername eingeben...';
  ClientDataSet1Passwort.AsString := 'Passwort eingeben...';
  ClientDataSet1Info.AsString := 'Ihre Notiz';
  ClientDataSet1isFavorit.AsBoolean := false;
  DBCheckBox1.Checked := false;

  pNodeData := DBTree.AVST.GetNodeData( pNode );
  if Assigned(pNodeData) then
  begin
    ParentData := DBTree.AVST.GetNodeData( pNode.Parent );

    pNodeData.Bezeichnung := ClientDataSet1Bezeichnung.AsString;
    pNodeData.Benutzername := ClientDataSet1Benutzername.AsString;
    pNodeData.Passwort := ClientDataSet1Passwort.AsString;
    pNodeData.Info := ClientDataSet1Info.AsString;
    pNodeData.isFavorit := ClientDataSet1isFavorit.AsBoolean;
    pNodeData.NodeIdx := DBTree.AVST.AbsoluteIndex( pNode );
    ClientDataSet1NodeIndex.AsString := IntToStr( pNodeData.NodeIdx );

    pNodeData.Ordner := ParentData.Bezeichnung;
    ClientDataSet1Ordner.AsString :=  pNodeData.Ordner;

    DBTree.TryExpandNode( pNode.Parent );
  end;
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
var
pNode : PVirtualNode;
begin
  DBCheckBox1.Enabled := true;
  pNode := DBTree.AddDBNodeAtStandart;
  ClientDataSet1.Insert;
  InitNewData( pNode );
  DBTree.AVST.AddToSelection( PNode, false );

  EnableDBFields( true );
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-06
-------------------------------------------------------------------------------}
procedure TMain.Button1Click(Sender: TObject);
begin
  ClientDataSet1.Delete;
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
Author: Seidel 2020-09-16
Change: 2020-09-17 -Toggle Fehler das false nicht in den Node Daten
        geschrieben wurde
-------------------------------------------------------------------------------}
procedure TMain.DBCheckBox1Click(Sender: TObject);
var
pNode, pNodeFav : PVirtualNode;
pData : pVTNodeData;
begin
  //fängt eine Exception beim Start ab
  if not Assigned( DBTree ) then
    Exit;

  pNode := DBTree.AVST.FocusedNode;
  pData := DBTree.AVST.GetNodeData( pNode );
  if Assigned( pData ) then
  begin
    pNodeFav := DBTree.AVST.GetFirstLevel( 1 );
    DBTree.AVST.MoveTo( pNode, pNodeFav, amAddChildLast, false );

    DBTree.TryExpandNode( pNodeFav );

    UpdateNodeEntry( Sender );
  end;
end;


{------------------------------------------------------------------------------
Author: Seidel 2020-09-16
-------------------------------------------------------------------------------}
procedure TMain.DBEditBenutzerClick(Sender: TObject);
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
Author: Seidel 2020-09-16
-------------------------------------------------------------------------------}
procedure TMain.DBEditBezeichnungClick(Sender: TObject);
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
Author: Seidel 2020-09-16
-------------------------------------------------------------------------------}
procedure TMain.DBEditPasswortClick(Sender: TObject);
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

  //XMLFile := 'D:\Delphi Embarcadero\Passwort_Manager\DB\Versuch4.xml';
  XMLFile := 'D:\Delphie Embarcadero\Passwort_Manager\DB\Versuch4.xml';

  if not FileExists(XMLFile) then
  begin
    opendialog := TFileOpenDialog.Create( nil );
    try
      openDialog.Title := 'Bitte Datenbank *.xml auswählen';
      if opendialog.Execute then
        XMLFile := opendialog.FileName;
    finally
      opendialog.Free;
    end;
  end;


  //{ClientDataSet1.FileName}XMLFile := 'D:\Delphi embarcadero\Passwort_Manager\DB\Versuch4.xml';
  ClientDataSet1.LoadFromFile( {ClientDataSet1.FileName}XMLFile );

  EnableDBFields( false );
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
Author: Seidel 2020-09-06
-------------------------------------------------------------------------------}
procedure TMain.SaveDataBtnClick(Sender: TObject);
begin
//TODO: der Pfad zu der Datei kann in ClientDataSet1.FileName gespeichert werden!
  ClientDataSet1.SaveToFile( {ClientDataSet1.FileName}XMLFile , dfXML);
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
  if pData^.Bezeichnung.Equals('Bezeichnung eingeben...') then
    CellText := '*Neuer Schlüssel'
  else
    CellText := pData^.Bezeichnung;
end;

end.
