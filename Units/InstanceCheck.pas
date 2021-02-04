unit InstanceCheck;

//*******************************************************************************************
// Bezeichung  : TInstanceCheck
// Typ         : Komponente
// Beschreibung: Stellt das Ereignis "OnNewInstance" zur Verfügung, welches ausgelöst wird,
//               wenn eine weitere Anwendungsinstanz initialisiert wird.
//               Parameter:
//                 ProcessId: Die Prozess-ID der neuen Anwendungsinstanz
//                 Params   : Die Liste der Startparameter
//                 Allow    : Gibt an ob die Instanz gestartet werden
//                            soll. (Rückgabeparameter, Standard: False)
//
// Autor       : Daniel Pauli, daniel.pauli@gmx.ch
// Version     : 1.0
// Status      : Lauffähig
// Geändert am : 19.07.2006
//*******************************************************************************************

interface

uses
  Windows, Messages, SysUtils, Classes, Forms, OneInstance;

type
  TOnNewInstance = procedure(Sender: TObject; ProcessId: Cardinal; Params: TStringList;
                     var Allow: Boolean) of object;

type
  TInstanceCheck = class(TComponent)
  private
    FOnNewInstance: TOnNewInstance;
  protected
    procedure DoNewInstance(ProcessId: Cardinal; CmdLine: String; var Allow: Boolean);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property OnNewInstance: TOnNewInstance read FOnNewInstance write FOnNewInstance;
  end;

  ECreateError = class(Exception);

  procedure Register;

  var
    GInstanceCheck: TInstanceCheck;

implementation

  {$R *.dcr}

  resourcestring
    MsgCreateError = 'Es kann nur ein einziges %s-Objekt erstellt werden';

  procedure Register;
  begin
    RegisterComponents('Eigene Komponenten', [TInstanceCheck]);
  end;

  {==[ Hilfsfunktionen ]======================================================================}

  function ForceForegroundWindow(const hWnd: HWND): Boolean;
  var
    ForegroundThreadID: DWORD;
    ThisThreadID: DWORD;
    Attached: Boolean;
  begin
    Result:= True;
    if IsIconic(hWnd) then ShowWindow(hWnd, SW_RESTORE);
    if GetForegroundWindow <> hWnd then
    begin
      ForegroundThreadID := GetWindowThreadProcessID(GetForegroundWindow, nil);
      ThisThreadID       := GetWindowThreadPRocessId(hWnd, nil);
      Attached           := AttachThreadInput(ThisThreadID, ForegroundThreadID, True);
      BringWindowToTop(hWnd);
      SetForegroundWindow(hWnd);
      if Attached then AttachThreadInput(ThisThreadID, ForegroundThreadID, False);
      Result := GetForegroundWindow = hWnd;
    end;
  end;

  procedure ExtractParams(const S: String; Params: TStringList);
    function SubStr(P1, P2: PChar): String;
    begin
      SetString(Result, P1, P2 - P1);
    end;
  var
    P1, P2: PChar;
    Quote: Boolean;
  begin
    Quote := False;
    P1 := PChar(S);
    P2 := P1;
    while P1^ <> #0 do
    begin
      while (P2^ <> #0) and ((P2^ <> ' ') or Quote) do
      begin
        if P2^ = '"' then Quote := not Quote;
        Inc(P2);
      end;
      Params.Add(SubStr(P1, P2));
      while P2^ = ' ' do Inc(P2);
      P1 := P2;
    end;
  end;

  {==[ Primärfunktionen ]=====================================================================}

  procedure NewInstProc(ProcessId: Cardinal; CmdLine: String; var Allow: Boolean);
  begin
    if Assigned(GInstanceCheck) then
    begin
      Allow:= False;
      GInstanceCheck.DoNewInstance(ProcessId, CmdLine, Allow);
    end else
      Allow:= True;
  end;

  { TInstanceCheck }

  constructor TInstanceCheck.Create(AOwner: TComponent);
  begin
    inherited Create(AOwner);
    if Assigned(GInstanceCheck) then
      raise ECreateError.CreateResFmt(@MsgCreateError, [ClassName]);
    GInstanceCheck:= Self;
  end;

  destructor TInstanceCheck.Destroy;
  begin
    GInstanceCheck := nil;
    inherited;
  end;

  procedure TInstanceCheck.DoNewInstance(ProcessId: Cardinal; CmdLine: String;
    var Allow: Boolean);
  var
    Params: TStringList;
  begin
    if Assigned(FOnNewInstance) then
    begin
      Params := TStringList.Create;
      try
        ExtractParams(CmdLine, Params);
        FOnNewInstance(Self, ProcessId, Params, Allow);
        if not Allow then
        begin
          Application.Restore;
          ForceForegroundWindow(Application.MainForm.Handle);
        end;
      finally
        Params.Free;
      end;
    end;
  end;

initialization
  OneInstance.NewInstProc := NewInstProc;

end.

