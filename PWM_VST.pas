unit PWM_VST;

interface

uses
  Vcl.StdCtrls, Vcl.DBCtrls, Virtualtrees, System.SysUtils;

Type
  TDBTree = class(Tobject)
    var AVST : TVirtualStringTree;
    private
      procedure SetFirstData;
      procedure SetData( pNode : PVirtualNode; isFolder : Boolean; Bezeichnung : String = '');
    public
      Constructor Create( VST : TVirtualStringTree ); overload; virtual;
      function AddDBNodeAtStandart : PVirtualNode;
      function AddDBNodeAt( ParentNode : PVirtualNode ) : PVirtualNode;
      procedure SetNodeDBID( Node : PVirtualNode; ID : Integer );
      procedure MoveNodeToFav( pNode : PVirtualNode );
      //TODO: AddDBNode bei einem bestimmten Ordner
      function AddDBNodeFolder : PVirtualNode;
      function IsAddedInFav( pNode : PVirtualNode) : Boolean;
      procedure FirstOpen;
      procedure TryExpandNode( pNode : PVirtualNode);
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
  Vcl.Dialogs, Main_PWM;

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
pData : pVTNodeData;
begin
  AVST.ClearSelection;
  AVST.Refresh;
  pNode := AVST.GetFirst();
  pData := AVST.GetNodeData(PNode);
  Result := AVST.AddChild( pNode );

  SetData( Result, true, 'Neuer Ordner' );

end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-17
-------------------------------------------------------------------------------}
function TDBTree.IsAddedInFav( pNode : PVirtualNode) : Boolean;
var
pData : pVTNodeData;
begin
  Result := false;
  pData := AVST.GetNodeData( pNode.Parent );
  if pData^.Bezeichnung.Equals('Favoriten') then
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
  //TODO: wenn es soweit ist, dann muss dem Node noch die ID des Datensatzen zugewiesen werden damit
  //dieser den DatenSatz ändert
  if isFolder then
  begin
    pData := AVST.GetNodeData( pNode );
    pData^.Bezeichnung := Bezeichnung;
    pData^.Benutzername := SC_NO_DATA;
    pData^.Passwort := SC_NO_DATA;
    pData^.Info := SC_NO_DATA;
    pData^.isFavorit := false;
    pData^.Ordner := SC_FOLDER;
    pData^.NodeIdx := AVST.AbsoluteIndex( pNode );
    pData^.NodeImageIdx := IC_FOLDER_OPEN;
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
    pData^.NodeIdx := AVST.AbsoluteIndex( pNode );
    pData^.NodeImageIdx := IC_KEY;
  end;

end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-06
-------------------------------------------------------------------------------}
procedure TDBTree.SetFirstData;
begin


end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-06
-------------------------------------------------------------------------------}
procedure TDBTree.FirstOpen;
var
pNode, pNode2 : PVirtualNode;
begin
  pNode := AVST.AddChild( nil );
  SetData( pNode, true, 'Passwort-Manager' );
  pNode2 := AVST.AddChild( pNode );
  SetData( pNode2, true, 'Favoriten' );
  pNode2 := AVST.AddChild( pNode );
  SetData( pNode2, true, 'Alle' );
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
  //suche nach dem Ordner 'Alle'
  Nodes := AVST.nodes;
  for pNode in Nodes do
  begin
    pData := AVST.GetNodeData( pNode );
    Bezeichnung := pData^.Bezeichnung;
    if Bezeichnung.Equals('Alle') then
    begin
      pChildNode := AVST.InsertNode( pNode, amAddChildLast );
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
pData, pChildData : pVTNodeData;
begin
  AVST.ClearSelection;
  AVST.Refresh;
  pChildNode := AVST.InsertNode( ParentNode, amAddChildFirst );
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
      if pDataFav^.Bezeichnung.Equals( 'Favoriten' ) then
      begin
        AVST.MoveTo( pNode, pNodeFav, amAddChildLast, false );
        TryExpandNode( pNodeFav );
      end;
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
