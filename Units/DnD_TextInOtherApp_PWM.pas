unit DnD_TextInOtherApp_PWM;

{******************************************************************************
Drag and Drop Handler von Texten "KiiTree"

Author: Sebastian Seidel
Author: Copyleft 2020 - 2021 Sebastian Seidel

*******************************************************************************}

interface

uses
  System.Classes,
  Vcl.Controls,
  MMSystem,
  DragDropText,
  DragDrop;

procedure CreateDropTextSource( AOwner: TComponent );
procedure CheckAndExecute( const TextToDrag : UnicodeString; Shift: TShiftState; Sender : TObject ) ;
procedure FreeDropTextSource();

implementation

var
  DropTextSource1: TDropTextSource;

procedure CheckAndExecute( const TextToDrag : UnicodeString; Shift: TShiftState; Sender : TObject ) ;
begin
  if ( Shift = [ssCtrl,ssleft] ) then //Strg + linke Maustaste
  begin
    if ( DragDetectPlus( Sender as TWinControl ) ) then
    begin
      DropTextSource1.UnicodeText := TextToDrag;
      DropTextSource1.Execute;
    end;
  end;
end;


procedure CreateDropTextSource( AOwner: TComponent );
begin
  DropTextSource1 := TDropTextSource.Create( AOwner ); //da keine Komponente erstmal erzeugen
  DropTextSource1.DragTypes := [dtCopy];               //und DragType zuweisen
end;


procedure FreeDropTextSource();
begin
  DropTextSource1.Free;
end;

end.
