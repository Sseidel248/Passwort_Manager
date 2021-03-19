unit Messages_PWM;

{******************************************************************************
Messages_PWM "KiiTree"

Author: Copyleft 2020 - 2021 Sebastian Seidel

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
    SetTDTexts( TD, 'Best�tige', 'Was m�chten Sie tun?', '' );

    TD.CommonButtons := [];

    AddTDButton( TD, 'Schlie�en', 'Die Anwendung wird beendet', mrClose, true );
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
    SetTDTexts( TD, 'Best�tige', 'Was m�chten Sie tun?', '' );

    TD.CommonButtons := [];

    AddTDButton( TD, 'Schlie�en', 'Die Anwendung wird beendet.', mrClose );
    AddTDButton( TD, 'Schlie�en und Leeren', 'Die Anwendung wird beendet und der Zwischenspeicher geleert', mrCloseNClear, true );
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
    SetTDTexts( TD, 'Best�tige', 'Es sind �nderungen vorhanden!', 'Sollen die �nderungen an Ihrem KiiTree gespeichert werden?' );

    TD.CommonButtons := [];

    AddTDButton( TD, 'Speichern', 'Die �nderungen werden gespeichert', mrYes, true );
    AddTDButton( TD, '�nderung verwerfen', 'Die �nderungen werden verworfen', mrNo );

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
    SetTDTexts( TD, 'Fehler', 'L�schen fehlgeschlagen!',
              'Die Ordner "Alle" oder "Favoriten" sind Standartverzeichnisse und sind vor versehntlichem L�schen gesch�tzt.' );

    TD.CommonButtons := [];

    AddTDButton( TD, 'Ok', 'Zur�ck zum Kiitree', mrOk );

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
      SetTDTexts( TD, 'Best�tige', 'Ordner L�schen?'
                  , 'Sind Sie sich sicher, dass Sie diesen Ordner l�schen wollen?' + sLineBreak
                  + 'Alle darin enthaltenden Schl�ssel werden ebenfalls gel�scht!'
                  + sLineBreak + sLineBreak
                  + 'Zu l�schender Ordner: "'
                  + Value + '"' );
    end
    else
    begin
      SetTDTexts( TD, 'Best�tige', 'Kii l�schen?'
                    , 'Sind Sie sich sicher, dass Sie diesen Kii l�schen wollen?'
                    + sLineBreak + sLineBreak
                    + 'Zu l�schender Kii: "'
                    + Value + '"' );
    end;

    TD.CommonButtons := [];

    AddTDButton( TD, 'L�schen', 'Das ausgew�hlte Objekt wird gel�scht', mrYes, true );
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
    SetTDTexts( TD, 'Fehler', '�ffnen fehlgeschlagen',
              'URL konnte nicht ge�ffnet werden, bitte �berpr�fen Sie Ihre URL.' );

    TD.CommonButtons := [];

    AddTDButton( TD, 'Ok', 'Zur�ck zum Kiitree', mrOk );

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
        + sLineBreak + 'Bitte pr�fen Sie, ob Ihr Speichermedium vorhanden ist bevor Sie speichern.';
    SetTDTexts( TD, 'Warnung', 'Pfad ist nicht verf�gbar', s1 );

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
    AddTDButton( TD, 'Nein', 'Zur�ck zum Loginfenster', mrNo );

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
      s1 := 'Ihre Datei ist m�glicherweise defekt. Bitte w�hlen Sie eine anderen Benutzer oder erstellen einen Neuen.'
    else
      s1 := 'Ihr Datei konnte in dem von Ihnen gew�hlten Verzeichnis nicht gefunden werden!' + sLineBreak + sLineBreak
    + 'Pr�fe Sie bitte, ob der richtige Pfad gew�hlt wurde oder w�hlen Sie einen anderes Verzeichnis.';

    SetTDTexts( TD, 'Warnung', 'Login fehlgeschlagen!', s1 );

    TD.CommonButtons := [];

    AddTDButton( TD, 'Ok', 'Zur�ck zum Loginfenster', mrOk );

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
    s1 := 'M�chten Sie den Benutzer neu erstellen?';

    SetTDTexts( TD, 'Hinweis', 'Benutzer Existiert nicht!', s1 );

    TD.CommonButtons := [];

    AddTDButton( TD, 'Ja', 'Zur�ck zum Loginfenster', mrYes, true );
    AddTDButton( TD, 'Nein', 'Zur�ck zum Loginfenster', mrNo );

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

    s1 := s1 + 'M�glicherweise verf�gt das von Ihnen ausgef�hrte Programm nicht �ber die notwendigen Rechte. '
        + 'Bitte f�hren sie Ihre Anwendung erneut als Administrator aus.' + slineBreak + slineBreak
        + 'Anwendung als Administrator ausf�hren: Rechtsklick auf die Anwendung und "Als Administrator ausf�hren" ausw�hlen.';

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
