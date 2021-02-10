unit Messages_PWM;

{******************************************************************************
Messages_PWM "KiiTree"

Author: Sebastian Seidel

Hier befinden sich alle Taskdialogs welches KiiTree benutzt.

*******************************************************************************}

interface

  function MessageMinOrClose(): Integer;
  function MessageMinClearOrClose(): Integer;
  function MessageSave(): Integer;
  procedure MessageSaveSuccess( const s : String );
  function MessageDelError(): Integer;
  function MessageDelete( const Value : String; IsFolder : Boolean = true ): Integer;
  function MessageOpenURLError() : Integer;
  function MessageDontFindDrive( const Savepath : String ): Integer;
  function MessageFindDrive(): Integer;
  function MessageFileCurrpt( Found : Boolean = true ): Integer;
  function MessageUserNotExist(): Integer;
  function MessageCantWriteAccessAndSaveIni( forCreate : Boolean = false ): Integer;
  procedure MessageTest( const Str : String);

const
  mrMini = 15;
  mrCloseNClear = 16;

implementation

uses
  System.UITypes,
  System.Notification,
  vcl.Dialogs;

{------------------------------------------------------------------------------
Author: Seidel 2021-01-30
-------------------------------------------------------------------------------}
procedure AddTDButton( var TD : TTaskdialog;
                      const ACaption, ACommandLinkHint : String;
                      const MResult : Integer;
                      const IsDefault : Boolean = false);
begin
  with TTaskDialogButtonItem(TD.Buttons.Add) do
  begin
    Caption := ACaption;
    ModalResult := MResult;
    CommandLinkHint := ACommandLinkHint;
    Default :=  IsDefault;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2021-01-30
-------------------------------------------------------------------------------}
procedure SetTDTexts( var TD : TTaskdialog;
                      const ACaption, ATitle, AText : String);
begin
  TD.Caption := ACaption;
  TD.Title := ATitle;
  TD.Text := AText;
end;

{------------------------------------------------------------------------------
Author: Seidel 2021-01-30
-------------------------------------------------------------------------------}
function MessageMinOrClose(): Integer;
var
TD : TTaskDialog;
begin
  TD := TTaskDialog.Create(nil);
  try
    SetTDTexts( TD, 'Bestätige', 'Was möchten Sie tun?', '' );

    TD.CommonButtons := [];

    AddTDButton( TD, 'Schließen', 'Die Anwendung wird beendet', mrClose, true );
    AddTDButton( TD, 'Minimieren', 'Die Anwendung wird in die Taskleiste minimiert', mrMini );

    TD.MainIcon := tdiInformation;
    TD.Flags := [tfUseCommandLinks, tfAllowDialogCancellation];
    if TD.Execute then
    begin
      Result := TD.ModalResult;
    end
    else
      Result := mrAbort;
  finally
    TD.Free;
  end
end;

{------------------------------------------------------------------------------
Author: Seidel 2021-01-30
-------------------------------------------------------------------------------}
function MessageMinClearOrClose(): Integer;
var
TD : TTaskDialog;
begin
  TD := TTaskDialog.Create(nil);
  try
    SetTDTexts( TD, 'Bestätige', 'Was möchten Sie tun?', '' );

    TD.CommonButtons := [];

    AddTDButton( TD, 'Schließen', 'Die Anwendung wird beendet.', mrClose );
    AddTDButton( TD, 'Schließen und Leeren', 'Die Anwendung wird beendet und der Zwischenspeicher geleert', mrCloseNClear, true );
    AddTDButton( TD, 'Minimieren', 'Die Anwendung wird in die Taskleiste minimiert', mrMini );

    TD.MainIcon := tdiInformation;
    TD.Flags := [tfUseCommandLinks, tfAllowDialogCancellation];
    if TD.Execute then
    begin
      Result := TD.ModalResult;
    end
    else
      Result := mrAbort;
  finally
    TD.Free;
  end
end;

{------------------------------------------------------------------------------
Author: Seidel 2021-02-03
-------------------------------------------------------------------------------}
function MessageSave(): Integer;
var
TD : TTaskDialog;
begin
  TD := TTaskDialog.Create(nil);
  try
    SetTDTexts( TD, 'Bestätige', 'Es sind Änderungen vorhanden!', 'Sollen die Änderungen an Ihrem KiiTree gespeichert werden?' );

    TD.CommonButtons := [];

    AddTDButton( TD, 'Speichern', 'Die Änderungen werden gespeichert', mrYes, true );
    AddTDButton( TD, 'Änderung verwerfen', 'Die Änderungen werden verworfen', mrNo );

    TD.MainIcon := tdiInformation;
    TD.Flags := [tfUseCommandLinks, tfAllowDialogCancellation];
    if TD.Execute then
    begin
      Result := TD.ModalResult;
    end
    else
      Result := mrAbort;
  finally
    TD.Free;
  end
end;

{------------------------------------------------------------------------------
Author: Seidel 2021-02-03
-------------------------------------------------------------------------------}
procedure MessageSaveSuccess( const s : String );
var
  appNotification: TNotification;
  appNC : TNotificationCenter;
begin
  appNC := TNotificationCenter.Create( nil );
  appNotification := appNC.CreateNotification;
  try
    appNotification.EnableSound := true;
    appNotification.Name := 'Kiitree';
    appNotification.Title := 'Speicherung von Kiitree';
    appNotification.AlertBody := s;
    appNC.PresentNotification(appNotification);
  finally
    appNotification.Free;
    appNC.Free;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2021-02-04
-------------------------------------------------------------------------------}
function MessageDelError(): Integer;
var
TD : TTaskDialog;
begin
  TD := TTaskDialog.Create(nil);
  try
    SetTDTexts( TD, 'Fehler', 'Löschen fehlgeschlagen!',
              'Die Ordner "Alle" oder "Favoriten" sind Standartverzeichnisse und sind vor versehntlichem Löschen geschützt.' );

    TD.CommonButtons := [];

    AddTDButton( TD, 'Ok', 'Zurück zum Kiitree', mrOk );

    TD.MainIcon := tdiError;
    TD.Flags := [tfUseCommandLinks, tfAllowDialogCancellation];
    if TD.Execute then
    begin
      Result := TD.ModalResult;
    end
    else
      Result := mrAbort;
  finally
    TD.Free;
  end
end;

{------------------------------------------------------------------------------
Author: Seidel 2021-02-04
-------------------------------------------------------------------------------}
function MessageDelete( const Value : String; IsFolder : Boolean = true ): Integer;
var
TD : TTaskDialog;
begin
  TD := TTaskDialog.Create(nil);
  try
    if IsFolder then
    begin
      SetTDTexts( TD, 'Bestätige', 'Ordner Löschen?'
                  , 'Sind Sie sich sicher, dass Sie diesen Ordner löschen wollen?' + sLineBreak
                  + 'Alle darin enthaltenden Schlüssel werden ebenfalls gelöscht!'
                  + sLineBreak + sLineBreak
                  + 'Zu löschender Ordner: "'
                  + Value + '"' );
    end
    else
    begin
      SetTDTexts( TD, 'Bestätige', 'Kii löschen?'
                    , 'Sind Sie sich sicher, dass Sie diesen Kii löschen wollen?'
                    + sLineBreak + sLineBreak
                    + 'Zu löschender Kii: "'
                    + Value + '"' );
    end;

    TD.CommonButtons := [];

    AddTDButton( TD, 'Löschen', 'Das ausgewählte Objekt wird gelöscht', mrYes, true );
    AddTDButton( TD, 'Abbrechen', '', mrNo );

    TD.MainIcon := tdiInformation;
    TD.Flags := [tfUseCommandLinks, tfAllowDialogCancellation];
    if TD.Execute then
    begin
      Result := TD.ModalResult;
    end
    else
      Result := mrAbort;
  finally
    TD.Free;
  end
end;

{------------------------------------------------------------------------------
Author: Seidel 2021-02-04
-------------------------------------------------------------------------------}
function MessageOpenURLError() : Integer;
var
TD : TTaskDialog;
begin
  TD := TTaskDialog.Create(nil);
  try
    SetTDTexts( TD, 'Fehler', 'Öffnen fehlgeschlagen',
              'URL konnte nicht geöffnet werden, bitte überprüfen Sie Ihre URL.' );

    TD.CommonButtons := [];

    AddTDButton( TD, 'Ok', 'Zurück zum Kiitree', mrOk );

    TD.MainIcon := tdiError;
    TD.Flags := [tfUseCommandLinks, tfAllowDialogCancellation];
    if TD.Execute then
    begin
      Result := TD.ModalResult;
    end
    else
      Result := mrAbort;
  finally
    TD.Free;
  end
end;

{------------------------------------------------------------------------------
Author: Seidel 2021-02-04
-------------------------------------------------------------------------------}
function MessageDontFindDrive( const Savepath : String ): Integer;
var
TD : TTaskDialog;
s1 : String;
begin
  TD := TTaskDialog.Create(nil);
  try
    s1 := 'Ihr Speicherpfad' + sLineBreak + '"' + SavePath + '"' + sLineBreak + 'existiert nicht mehr!'
        + sLineBreak + 'Bitte prüfen Sie, ob Ihr Speichermedium vorhanden ist bevor Sie speichern.';
    SetTDTexts( TD, 'Warnung', 'Pfad ist nicht verfügbar', s1 );

    TD.CommonButtons := [];

    AddTDButton( TD, 'Wiederholen', 'Nochmal versuchen den Speicherpfad zu finden', mrRetry, true );
    AddTDButton( TD, 'Abbrechen', 'Speichervorgang wird abgebrochen', mrCancel );

    TD.MainIcon := tdiWarning;
    TD.Flags := [tfUseCommandLinks, tfAllowDialogCancellation];
    if TD.Execute then
    begin
      Result := TD.ModalResult;
    end
    else
      Result := mrAbort;
  finally
    TD.Free;
  end
end;

{------------------------------------------------------------------------------
Author: Seidel 2021-02-04
-------------------------------------------------------------------------------}
function MessageFindDrive(): Integer;
var
TD : TTaskDialog;
s1 : String;
begin
  TD := TTaskDialog.Create(nil);
  try
    s1 := 'Es wurde ein USB-Speicher eingesteckt!' + sLineBreak
          + 'Wollen Sie diesen USB verwenden?';
    SetTDTexts( TD, 'Hinweis', 'Speichermedium erkannt!', s1 );

    TD.CommonButtons := [];

    AddTDButton( TD, 'Ja', 'Der USB-Stick wird zum speichern verwendet', mrYes, true );
    AddTDButton( TD, 'Nein', 'Zurück zum Loginfenster', mrNo );

    TD.MainIcon := tdiInformation;
    TD.Flags := [tfUseCommandLinks, tfAllowDialogCancellation];
    if TD.Execute then
    begin
      Result := TD.ModalResult;
    end
    else
      Result := mrAbort;
  finally
    TD.Free;
  end
end;

{------------------------------------------------------------------------------
Author: Seidel 2021-02-04
-------------------------------------------------------------------------------}
function MessageFileCurrpt( Found : Boolean = true  ): Integer;
var
TD : TTaskDialog;
s1 : String;
begin
  TD := TTaskDialog.Create(nil);
  try
    if Found then
      s1 := 'Ihre Datei ist möglicherweise defekt. Bitte wählen Sie eine anderen Benutzer oder erstellen einen Neuen.'
    else
      s1 := 'Ihr Datei konnte in dem von Ihnen gewählten Verzeichnis nicht gefunden werden!' + sLineBreak + sLineBreak
    + 'Prüfe Sie bitte, ob der richtige Pfad gewählt wurde oder wählen Sie einen anderes Verzeichnis.';

    SetTDTexts( TD, 'Warnung', 'Login fehlgeschlagen!', s1 );

    TD.CommonButtons := [];

    AddTDButton( TD, 'Ok', 'Zurück zum Loginfenster', mrOk );

    TD.MainIcon := tdiError;
    TD.Flags := [tfUseCommandLinks, tfAllowDialogCancellation];
    if TD.Execute then
    begin
      Result := TD.ModalResult;
    end
    else
      Result := mrAbort;
  finally
    TD.Free;
  end
end;

{------------------------------------------------------------------------------
Author: Seidel 2021-02-04
-------------------------------------------------------------------------------}
function MessageUserNotExist(): Integer;
var
TD : TTaskDialog;
s1 : String;
begin
  TD := TTaskDialog.Create(nil);
  try
    s1 := 'Möchten Sie den Benutzer neu erstellen?';

    SetTDTexts( TD, 'Hinweis', 'Benutzer Existiert nicht!', s1 );

    TD.CommonButtons := [];

    AddTDButton( TD, 'Ja', 'Zurück zum Loginfenster', mrYes, true );
    AddTDButton( TD, 'Nein', 'Zurück zum Loginfenster', mrNo );

    TD.MainIcon := tdiInformation;
    TD.Flags := [tfUseCommandLinks, tfAllowDialogCancellation];
    if TD.Execute then
    begin
      Result := TD.ModalResult;
    end
    else
      Result := mrAbort;
  finally
    TD.Free;
  end
end;

{------------------------------------------------------------------------------
Author: Seidel 2021-02-04
-------------------------------------------------------------------------------}
function MessageCantWriteAccessAndSaveIni( forCreate : Boolean = false ): Integer;
var
TD : TTaskDialog;
s1 : String;
begin
  TD := TTaskDialog.Create(nil);
  try
    if forCreate then
      s1 := 'Beim Starten ihrer Anwendung ist ein Fehler aufgetreten!' + slineBreak + slineBreak
    else
      s1 := 'Beim speichern ihrer Einstellungen ist ein Fehler aufgetreten!' + slineBreak + slineBreak;

    s1 := s1 + 'Möglicherweise verfügt das von Ihnen ausgeführte Programm nicht über die notwendigen Rechte. '
        + 'Bitte führen sie Ihre Anwendung erneut als Administrator aus.' + slineBreak + slineBreak
        + 'Anwendung als Administrator ausführen: Rechtsklick auf die Anwendung und "Als Administrator ausführen" auswählen.';

    SetTDTexts( TD, 'Fehler', 'Mangelnde Programm Berechtigungen!', s1 );

    TD.CommonButtons := [];

    AddTDButton( TD, 'Ok', 'Programm wird geschlossen', mrOk );

    TD.MainIcon := tdiError;
    TD.Flags := [tfUseCommandLinks, tfAllowDialogCancellation];
    if TD.Execute then
    begin
      Result := TD.ModalResult;
    end
    else
      Result := mrAbort;
  finally
    TD.Free;
  end
end;

{------------------------------------------------------------------------------
Author: Seidel 2021-02-09
-------------------------------------------------------------------------------}
procedure MessageTest( const Str : String);
begin
  {$IFDEF DEBUG}
  MessageDlg( Str, mtInformation, [mbOK], 0 );
  {$ENDIF}
end;

end.
