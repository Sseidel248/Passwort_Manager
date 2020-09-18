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
    PopupMenu1: TPopupMenu;
    NeuerOrdner1: TMenuItem;
    NeuerSchlssel1: TMenuItem;
    N1: TMenuItem;
    ZuFavoritenhinzufgen1: TMenuItem;
    N2: TMenuItem;
    Ordnerlschen1: TMenuItem;
    Schlssellschen1: TMenuItem;
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
    procedure VSTNodeClick(Sender: TBaseVirtualTree; const HitInfo: THitInfo);
    procedure DBCheckBox1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure NeuerOrdner1Click(Sender: TObject);
    procedure NeuerSchlssel1Click(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
  private
    AFonts : TFonts;
    DBTree : TDBTree;
    procedure AddNewDataSet;
    procedure InitNewData( pNode : pVirtualNode = nil; AddedInFav : Boolean = false);
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
  ClientDataSet1NodeImageIndex.AsInteger := pData^.NodeImageIdx;

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
    pNodeData.NodeIdx := DBTree.AVST.AbsoluteIndex( pNode );
    ClientDataSet1NodeIndex.AsString := IntToStr( pNodeData.NodeIdx );

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

  XMLFile := 'D:\Delphi Embarcadero\Passwort_Manager\DB\Table5.xml';
  //XMLFile := 'D:\Delphie Embarcadero\Passwort_Manager\DB\Table5.xml';

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
  end
  else
  begin
    //Nodelevel = 1 -> Odner der einzelnen Schlüssel
    if DBTree.AVST.GetNodeLevel( pNode ) = 1 then
    begin
      NeuerSchlssel1.Enabled        := true;
      NeuerOrdner1.Enabled          := true;
      ZuFavoritenhinzufgen1.Enabled := false;
      Ordnerlschen1.Enabled         := true;
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

      NeuerOrdner1.Caption := 'Neuer Unterordner';
    end;

  end;
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
  HintText := 'ID: ' + IntToStr( pData^.ID ) + sLineBreak
              +'Bezeichnung: ' + pData^.Bezeichnung + sLineBreak
              +'Benutzername: ' +  pData^.Benutzername + sLineBreak
              +'Passwort: ' +  pData^.Passwort + sLineBreak
              +'Ordner: ' +  pData^.Ordner + sLineBreak
              +'Nodeindex: ' +  IntToStr ( pData^.NodeIdx ) + sLineBreak
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
      pParentData := VST.GetNodeData( Node.Parent );
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
  pData := VST.GetNodeData( Node );
  if pData^.Bezeichnung.Equals('Bezeichnung eingeben...') then
    CellText := '*Neuer Schlüssel'
  else
    CellText := pData^.Bezeichnung;
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
