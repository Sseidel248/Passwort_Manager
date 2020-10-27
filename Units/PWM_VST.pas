unit PWM_VST;

{******************************************************************************
Datenbank und Node Bearbeitung von "KiiTree"
Author: Sebastian Seidel

*******************************************************************************}

interface

uses
  Vcl.StdCtrls, Vcl.DBCtrls, Virtualtrees, System.SysUtils, System.Classes, System.UITypes,
  Datasnap.DBClient;

Type
  TDBTree = class(Tobject)
    var AVST : TVirtualStringTree;
    private
      procedure SetData( pNode : PVirtualNode; isFolder : Boolean; Bezeichnung : String = ''); overload;
      procedure SetData( pNode : PVirtualNode; CDS : TClientDataSet); overload;
      procedure CreateNodeAfterLoad( CDS : TClientDataSet;
                                        Nodes : TVTVirtualNodeEnumeration );
      procedure CreateFolderNodeAfterLoad( Nodes : TVTVirtualNodeEnumeration;
                                              FolderNameList : TStringList );
//      function AddDBNodeAtStandartWithoutData( Nodes : TVTVirtualNodeEnumeration ) : PVirtualNode;
      function AddDBNodeWithoutDataAt( Nodes : TVTVirtualNodeEnumeration; Ordner : String ) : PVirtualNode;
    public
      Constructor Create( VST : TVirtualStringTree ); overload; virtual;
      procedure FirstOpen;
      function AddDBNodeAtStandart : PVirtualNode;
      function AddDBNodeAt( ParentNode : PVirtualNode ) : PVirtualNode;
      procedure SetNodeDBID( Node : PVirtualNode; ID : Integer );
      procedure MoveNodeToFav( pNode : PVirtualNode );
      procedure MoveNodeTo( pNode : PVirtualNode; Location : String);
      function AddDBNodeFolder : PVirtualNode;
      function IsAddedInFav( pNode : PVirtualNode) : Boolean;
      function IsFavFolder( pNode : PVirtualNode ) : Boolean;
      function IsAddedInAll( pNode : PVirtualNode) : Boolean;
      function IsAllFolder( pNode : PVirtualNode ) : Boolean;
      procedure TryExpandNode( pNode : PVirtualNode);
      procedure DelFolder;
      procedure DelDBNode;
      procedure RenameDBFolder;
      procedure LoadNodes( Nodes : TVTVirtualNodeEnumeration;
                             FolderNameList : TStringList;
                             CDS : TClientDataSet );
      procedure FilterTree( const Bezeichnung : String);
      procedure UnfilterAllTree;
  end;

procedure TogglePWSign( Edit : TCustomEdit; hide : Boolean );

const
  SC_NO_DATA    = 'NO_DATA';
  SC_FOLDER     = 'FOLDER';
  SC_FILE       = 'FILE';

  IC_FOLDER_OPEN      = 0;
  IC_FOLDER_CLOSE     = 1;
  IC_FAV_FOLDER_CLOSE = 2;
  IC_KEY              = 3;
  IC_KEY_SEL          = 4;
  IC_FAVORIT          = 5;

implementation

uses
  Vcl.Dialogs, Main_PWM, Global_PWM, System.StrUtils;

{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
TDBTree Klasse
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

{------------------------------------------------------------------------------
Author: Seidel 2020-09-06
-------------------------------------------------------------------------------}
Constructor TDBTree.Create( VST : TVirtualStringTree );
begin
  inherited Create;
  AVST := VST;
  AVST.NodeDataSize := SizeOf( rVTNodeData );
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-17
-------------------------------------------------------------------------------}
function TDBTree.AddDBNodeFolder : PVirtualNode;
var
pNode : PVirtualNode;
//pData : pVTNodeData;
begin
  AVST.ClearSelection;
  AVST.Refresh;
  pNode := AVST.GetFirst();
//  pData := AVST.GetNodeData(PNode);
  Result := AVST.InsertNode( pNode,amAddChildLast );

  SetData( Result, true, 'Neuer Ordner' );

  AVST.Selected[ Result ] := true;
  AVST.FocusedNode := Result;
  AVST.Refresh;
  Avst.EditNode( Result, -1 );

end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-17
-------------------------------------------------------------------------------}
function TDBTree.IsAddedInFav( pNode : PVirtualNode ) : Boolean;
var
pData : pVTNodeData;
begin
  Result := false;
  pData := AVST.GetNodeData( pNode.Parent );
  if pData^.Bezeichnung.Equals( SC_FAVORITEN ) then
  begin
    Result := true;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-18
-------------------------------------------------------------------------------}
function TDBTree.IsFavFolder( pNode : PVirtualNode ) : Boolean;
var
pData : pVTNodeData;
begin
  Result := false;
  pData := AVST.GetNodeData( pNode );
  if pData^.Bezeichnung.Equals( SC_FAVORITEN ) then
  begin
    Result := true;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-18
-------------------------------------------------------------------------------}
function TDBTree.IsAddedInAll( pNode : PVirtualNode) : Boolean;
  var
pData : pVTNodeData;
begin
  Result := false;
  pData := AVST.GetNodeData( pNode.Parent );
  if pData^.Bezeichnung.Equals( SC_ALLE ) then
  begin
    Result := true;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-18
-------------------------------------------------------------------------------}
function TDBTree.IsAllFolder( pNode : PVirtualNode ) : Boolean;
var
pData : pVTNodeData;
begin
  Result := false;
  pData := AVST.GetNodeData( pNode );
  if pData^.Bezeichnung.Equals( SC_ALLE ) then
  begin
    Result := true;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-06
-------------------------------------------------------------------------------}
procedure TDBTree.SetData( pNode : PVirtualNode; isFolder : Boolean; Bezeichnung : String = '');
var
pData : pVTNodeData;
begin
  if isFolder then
  begin
    pData := AVST.GetNodeData( pNode );
    pData^.Bezeichnung := Bezeichnung;
    pData^.Benutzername := SC_NO_DATA;
    pData^.Passwort := SC_NO_DATA;
    pData^.Info := SC_NO_DATA;
    pData^.isFavorit := false;
    pData^.Ordner := SC_FOLDER;
    pData^.NodeImageIdx := IC_FOLDER_OPEN;
    pData^.URL := SC_NO_DATA;
  end
  else
  begin
    pData := AVST.GetNodeData( pNode );
    pData^.Bezeichnung := '*Neuer Schlüssel';
    pData^.Benutzername := Main.DBEditBenutzer.Text;
    pData^.Passwort := Main.DBEditPasswort.Text;
    pData^.Info := Main.DBMemoInfo.Text;
    pData^.isFavorit := false;
    pData^.Ordner := SC_FILE;
    pData^.NodeImageIdx := IC_KEY;
    pData^.URL := SC_NO_DATA;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-19
-------------------------------------------------------------------------------}
procedure TDBTree.SetData( pNode : PVirtualNode; CDS : TClientDataSet);
var
pData : pVTNodeData;
begin
  pData := AVST.GetNodeData( pNode );
  pData^.ID           := CDS.Fields[0].AsInteger;
  pData^.Bezeichnung  := CDS.Fields[1].AsString;
  pData^.Benutzername := CDS.Fields[2].AsString;
  pData^.Passwort     := CDS.Fields[3].AsString;
  pData^.Info         := CDS.Fields[4].AsString;
  pData^.isFavorit    := CDS.Fields[7].AsBoolean;
  pData^.Ordner       := SC_FILE;
  pData^.NodeImageIdx := CDS.Fields[6].AsInteger;
  pData^.URL          := CDS.Fields[8].AsString;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-06
-------------------------------------------------------------------------------}
procedure TDBTree.FirstOpen;
var
pNode, pNode2 : PVirtualNode;
begin
  pNode := AVST.AddChild( nil );
  SetData( pNode, true, 'Ihr KiiTree' );
  pNode2 := AVST.AddChild( pNode );
  SetData( pNode2, true,  SC_FAVORITEN  );
  pNode2 := AVST.AddChild( pNode );
  SetData( pNode2, true, SC_ALLE );
  AVST.FullExpand();
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-06
-------------------------------------------------------------------------------}
procedure TDBTree.TryExpandNode( pNode : PVirtualNode );
begin
  if not AVST.Expanded[ pNode ] then
    AVST.FullExpand( PNode );

end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-18
-------------------------------------------------------------------------------}
procedure TDBTree.DelFolder;
var
pNode, pChild : PVirtualNode;
pData, pDataChild : pVTNodeData;
begin
  pNode := AVST.FocusedNode;
  pData := AVST.GetNodeData( pNode );
  if AVST.HasChildren[ pNode ] then
  begin
    if MessageDlg( 'Sind Sie sich sicher, dass Sie diesen Ordner löschen wollen?' + sLineBreak
                + 'Alle darin enthaltenden Schlüssel werden ebenfalls gelöscht!'
                + sLineBreak + sLineBreak
                + 'Zu löschender Ordner: "'
                + pData^.Bezeichnung + '"',
                mtWarning,
                [mbYes, mbNo], 0, mbNo ) = 6 then //Ja Btn gedrückt
    begin
      while AVST.HasChildren[ pNode ] do
      begin
        pChild := AVST.GetFirstChild( pNode );
        pDataChild := AVST.GetNodeData( pChild );
        Main.ClientDataSet1.Locate( 'ID', pDataChild^.ID , [] );
        Main.ClientDataSet1.Delete;
        //ShowMessage( 'Node mit idx: ' + inttoStr(pDataChild^.NodeIdx) + ' und Dataset mit ID: ' + inttoStr(pDataChild^.ID) + ' gelöscht');
        AVST.DeleteNode( pChild );
      end;
      AVST.DeleteNode( pNode );
    end;
  end
  else
  begin  //Change 2020-10-15 sicherheitsabfrage hinzugefügt
    if MessageDlg( 'Sind Sie sich sicher, dass Sie diesen Ordner löschen wollen?'
                + sLineBreak + sLineBreak
                + 'Zu löschender Ordner: "'
                + pData^.Bezeichnung + '"',
                mtWarning,
                [mbYes, mbNo], 0, mbNo ) = 6 then //Ja Btn gedrückt
      AVST.DeleteNode( pNode );
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-18
-------------------------------------------------------------------------------}
procedure TDBTree.DelDBNode;
var
pNode: PVirtualNode;
pData : pVTNodeData;
begin
  pNode := AVST.FocusedNode;
  pData := AVST.GetNodeData( pNode );
  if MessageDlg( 'Sind Sie sich sicher, dass Sie den Schlüssel löschen wollen?'
                + sLineBreak + sLineBreak
                + 'Zu löschender Schlüssel: "'
                + pData^.Bezeichnung + '"',
                mtWarning,
                [mbYes, mbNo], 0, mbNo ) = 6 then //Ja Btn gedrückt
  begin
    Main.ClientDataSet1.Locate( 'ID', pData^.ID , [] );
    Main.ClientDataSet1.Delete;
    AVST.DeleteNode( pNode );
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-18
-------------------------------------------------------------------------------}
procedure TDBTree.RenameDBFolder;
var
pNode: PVirtualNode;
begin
  AVST.TreeOptions.MiscOptions := AVST.TreeOptions.MiscOptions + [toEditable];

  pNode := AVST.FocusedNode;
  AVST.EditNode( pNode, -1 ); //benennt den Ordner um

  AVST.TreeOptions.MiscOptions := AVST.TreeOptions.MiscOptions - [toEditable];
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-19
-------------------------------------------------------------------------------}
//function TDBTree.AddDBNodeAtStandartWithoutData( Nodes : TVTVirtualNodeEnumeration ) : PVirtualNode;
//var
//pNode : PVirtualNode;
//pData : pVTNodeData;
//pChildNode : PVirtualNode;
//Bezeichnung : String;
//begin
//  AVST.ClearSelection;
//  AVST.Refresh;
//  //suche nach dem Ordner 'Alle'
//  for pNode in Nodes do
//  begin
//    pData := AVST.GetNodeData( pNode );
//    Bezeichnung := pData^.Bezeichnung;
//    if Bezeichnung.Equals( SC_ALLE ) then
//    begin
//      pChildNode := AVST.AddChild( pNode );
//      break;
//    end;
//  end;
//
//  Result := pChildNode;
//end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-19
-------------------------------------------------------------------------------}
function TDBTree.AddDBNodeWithoutDataAt( Nodes : TVTVirtualNodeEnumeration; Ordner : String ) : PVirtualNode;
var
pNode : PVirtualNode;
pData : pVTNodeData;
pChildNode : PVirtualNode;
Bezeichnung : String;
begin
  AVST.ClearSelection;
  AVST.Refresh;
  pChildNode := nil;
  //suche nach dem Ordner "Alle"
  for pNode in Nodes do
  begin
    pData := AVST.GetNodeData( pNode );
    Bezeichnung := pData^.Bezeichnung;
    if Bezeichnung.Equals( Ordner ) then
    begin
      pChildNode := AVST.AddChild( pNode );
      break;
    end;
  end;

  Result := pChildNode;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-19
-------------------------------------------------------------------------------}
procedure TDBTree.CreateFolderNodeAfterLoad( Nodes : TVTVirtualNodeEnumeration;
                             FolderNameList : TStringList );
var
pNode, pHauptNode, pNeuerNode : PVirtualNode;
pData : pVTNodeData;
N: Integer;
vorhanden : Boolean;
begin
  //prüfen ob in der Liste ein Ordnername steht der keine passende Node Bezeichnung hat
  for N := 0 to FoldernameList.Count-1 do
  begin
    vorhanden := false;
    //von den Standartvorhandenen Nodes wird geguckt welche es gibt und welche nicht
    for pNode in Nodes do
    begin
      pData := AVST.GetNodeData( pNode );
      //damit Nur die Unterordner genommen werden
      if AVST.GetNodeLevel( pNode ) = 1 then
      begin
        //Ordner existiert nicht
        if FolderNameList[N].Equals( pData^.Bezeichnung ) then
        begin
          vorhanden := true;
        end;
      end;
    end;
    if not vorhanden then
    begin
      pHauptNode := AVST.GetFirst();
      pNeuernode := AVST.AddChild( pHauptNode );
      SetData( pNeuerNode, true, FolderNameList[N] );
    end;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-19
-------------------------------------------------------------------------------}
procedure TDBTree.CreateNodeAfterLoad( CDS : TClientDataSet;
                                        Nodes : TVTVirtualNodeEnumeration );
var
pNode : PVirtualNode;
Ordner : String;
I, Max_ID : Integer;
begin
  Max_ID := Main.GetMaxID;
  for I := 0 to {CDS.RecordCount-1}Max_ID do
  begin
    if CDS.Locate( 'ID', I+1, [] ) then
    begin
      Ordner := CDS.Fields[5].AsString;
      pNode := AddDBNodeWithoutDataAt( Nodes, Ordner );
      SetData( pNode, CDS );
    end;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-21
-------------------------------------------------------------------------------}
procedure TDBTree.FilterTree( const Bezeichnung : String );
var
Nodes, Children : TVTVirtualNodeEnumeration;
pNode, pChild : PVirtualNode;
pChildData : pVTNodeData;
begin
  Nodes := AVST.Nodes();
  for pNode in Nodes do
  begin
    if AVST.GetNodeLevel( pNode ) = 1 then
    begin
      Children := AVST.ChildNodes( pNode );
      for pChild in Children do
      begin
        pChildData := AVST.GetNodeData( pChild );

        if not ContainsText( pChildData^.Bezeichnung, Bezeichnung ) then //Change 2020-10-12
          AVST.IsVisible[pChild] := false
        else
          AVST.IsVisible[pChild] := true;
      end;
    end;
  end;
  AVST.Refresh;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-21
-------------------------------------------------------------------------------}
procedure TDBTree.UnfilterAllTree;
var
Nodes, Children : TVTVirtualNodeEnumeration;
pNode, pChild : PVirtualNode;
begin
  Nodes := AVST.Nodes();
  for pNode in Nodes do
  begin
    if AVST.GetNodeLevel( pNode ) = 1 then
    begin
      Children := AVST.ChildNodes( pNode );
      for pChild in Children do
      begin
        if not AVST.IsVisible[pChild] then
          AVST.IsVisible[pChild] := true;
      end;
    end;
  end;
  AVST.Refresh;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-19
-------------------------------------------------------------------------------}
procedure TDBTree.LoadNodes( Nodes : TVTVirtualNodeEnumeration;
                             FolderNameList : TStringList;
                             CDS : TClientDataSet);
begin
  CreateFolderNodeAfterLoad( Nodes, FolderNameList );
  CreateNodeAfterLoad( CDS, Nodes );
//  MoveNodeAfterLoad;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-06
-------------------------------------------------------------------------------}
function TDBTree.AddDBNodeAtStandart : PVirtualNode;
var
pNode : PVirtualNode;
pData : pVTNodeData;
Nodes :TVTVirtualNodeEnumeration;
pChildNode : PVirtualNode;
Bezeichnung : String;
begin
  AVST.ClearSelection;
  AVST.Refresh;
  pChildNode := nil;
  //suche nach dem Ordner "Alle"
  Nodes := AVST.nodes;
  for pNode in Nodes do
  begin
    pData := AVST.GetNodeData( pNode );
    Bezeichnung := pData^.Bezeichnung;
    if Bezeichnung.Equals( SC_ALLE ) then
    begin
      pChildNode := AVST.AddChild( pNode );
      break;
    end;
  end;

  SetData( pChildNode, false );
  Result := pChildNode;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-17
-------------------------------------------------------------------------------}
function TDBTree.AddDBNodeAt( ParentNode : PVirtualNode ) : PVirtualNode;
var
pChildNode : PVirtualNode;
begin
  AVST.ClearSelection;
  AVST.Refresh;
  pChildNode := AVST.AddChild( ParentNode );
  SetData( pChildNode, false );
  Result := pChildNode;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-17
-------------------------------------------------------------------------------}
procedure TDBTree.SetNodeDBID( Node : PVirtualNode; ID : Integer );
var
pData : pVTNodeData;
begin
  pData := AVST.GetNodeData( Node );
  pData^.ID := ID;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-18
-------------------------------------------------------------------------------}
procedure TDBTree.MoveNodeToFav( pNode : PVirtualNode );
var
pData, pDataFav : pVTNodeData;
Nodes : TVTVirtualNodeEnumeration;
pNodeFav : PVirtualNode;
begin
  pData := AVST.GetNodeData( pNode );
  if pData.isFavorit = false then
  begin
    Nodes := AVST.Nodes();
    for pNodeFav in Nodes do
    begin
      pDataFav := AVST.GetNodeData( pNodeFav );
      if pDataFav^.Bezeichnung.Equals( SC_FAVORITEN ) then
      begin
        AVST.MoveTo( pNode, pNodeFav, amAddChildFirst, false );
        TryExpandNode( pNodeFav );
      end;
    end;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-04
-------------------------------------------------------------------------------}
procedure TDBTree.MoveNodeTo( pNode : PVirtualNode; Location : String);
var
{pData,} pDataFav : pVTNodeData;
Nodes : TVTVirtualNodeEnumeration;
pNodeFav : PVirtualNode;
begin
//  pData := AVST.GetNodeData( pNode );
  Nodes := AVST.Nodes();
  for pNodeFav in Nodes do
  begin
    pDataFav := AVST.GetNodeData( pNodeFav );
    if pDataFav^.Bezeichnung.Equals( Location ) then
    begin
      AVST.MoveTo( pNode, pNodeFav, amAddChildFirst, false );
      TryExpandNode( pNodeFav );
    end;
  end;
end;

{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
TDBTree Klasse Ende
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}


{------------------------------------------------------------------------------
Author: Seidel 2020-09-06
-------------------------------------------------------------------------------}
procedure TogglePWSign( Edit : TCustomEdit; hide : Boolean );
begin
  if Edit is TEdit then
  begin
    if hide then
      (Edit as TEdit).PasswordChar := '*'
    else
      (Edit as TEdit).PasswordChar := #0;
  end
  else if Edit is TDBEdit then
  begin
    if hide then
      (Edit as TDBEdit).PasswordChar := '*'
    else
      (Edit as TEdit).PasswordChar := #0;
  end
  else
    Exit;
end;

end.
