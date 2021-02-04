unit OneInstance;

//*******************************************************************************************
// Bezeichung  : OneInstance
// Typ         : Initialisations-Unit, NonVCL
// Beschreibung: Prüft während der Programm-Initialisation auf eine bereits laufende
//               Anwendungsinstanz, benachrichtigt diese und beendet ggf. die neue Instanz
//
//               - Wird diese Unit in einer beliebigen Uses-Klausel eines Projekts
//                 aufgeführt, wird standardmässig nur eine Anwendungsinstanz zugelassen.
//               - Durch eine Zuweisung von OneInstance.NewInstProc kann eine Ereignis-
//                 prozedur definiert werden, welche beim Start einer neuen Anwendungsinstanz
//                 aufgerufen wird. Parameter:
//                   ProcessId: Die Prozess-ID der neuen Anwendungsinstanz
//                   CmdLine  : Enthält Anwendungspfad sowie Startparameter
//                   Allow    : Gibt an ob die Instanz gestartet werden
//                              soll. (Rückgabeparameter, Standard: False)
//
// Autor       : Daniel Pauli, daniel.pauli@gmx.ch
// Version     : 1.0
// Status      : Lauffähig
// Geändert am : 19.07.2006
//*******************************************************************************************

interface

  uses
    Windows, Messages;

  type
    TNewInstProc = procedure(ProcessId: Cardinal; CmdLine: String; var Allow: Boolean);

  var
    NewInstProc: TNewInstProc;

implementation

  const
    INSTANCE_ALLOW = LRESULT($DA860080);
    INSTANCE_DENY  = LRESULT($DA860081);

  var
    hUtil: HWND;
    UtilWndClassName: String;

  {==[ Hilfsfunktionen ]======================================================================}

  function StrLen(const Str: PChar): Cardinal;
  var
    P: PChar;
  begin
    P := Str;
    while P^ <> #0 do Inc(P);
    Result := P - Str;
  end;

  {==[ Primärfunktionen ]=====================================================================}

  function UtilWindowProc(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
    stdcall;
  const
    Results: array[Boolean] of LRESULT = (INSTANCE_DENY, INSTANCE_ALLOW);
  var
    ProcessId: Cardinal;
    CmdLine: String;
    Allow: Boolean;
  begin
    if (Msg = WM_COPYDATA) and (wParam = 0) and (lParam <> 0) then
    begin
      Allow := False;
      if Assigned(NewInstProc) then
      begin
        with PCopyDataStruct(lParam)^ do
        begin
          ProcessId := hWnd;
          SetString(CmdLine, PChar(lpData), cbData div SizeOf(Char));
        end;
        NewInstProc(ProcessId, CmdLine, Allow);
      end;
      Result := Results[Allow];
    end else
      Result := DefWindowProc(hWnd, Msg, wParam, lParam);
  end;

  function CreateUtilWnd: HWND;
  var
    UtilWndClass: TWndClass;
  begin
    FillChar(UtilWndClass, SizeOf(UtilWndClass), 0);
    UtilWndClass.hInstance     := HInstance;
    UtilWndClass.lpfnWndProc   := @UtilWindowProc;
    UtilWndClass.lpszClassName := PChar(UtilWndClassName);
    RegisterClass(UtilWndClass);
    Result := CreateWindowEx(WS_EX_TOOLWINDOW, UtilWndClass.lpszClassName,
      '', WS_POPUP, 0, 0, 0, 0, 0, 0, HInstance, nil);
  end;

  procedure CheckInstance;
  var
    hMain: HWND;
    CDS: TCopyDataStruct;
  begin
    hMain := FindWindow(PChar(UtilWndClassName), nil);
    if hMain <> 0 then  // Anwendungsinstanz vorhanden
    begin
      with CDS do
      begin
        dwData := GetCurrentProcessId;
        lpData := GetCommandLine;
        cbData := StrLen(lpData) * SizeOf(Char);
      end;
      if SendMessage(hMain, WM_COPYDATA, 0, LPARAM(@CDS)) = INSTANCE_DENY then
        Halt; // Anwendung abbrechen. Anmerkung: Finalization-Abschnitte für bereits
              // initialisierte Units werden noch abgearbeitet.
    end;
  end;

initialization
  UtilWndClassName := 'OneInstUtilWnd:' + ParamStr(0);
  CheckInstance;
  hUtil := CreateUtilWnd;

finalization
  if hUtil <> 0 then DestroyWindow(hUtil);

end.

