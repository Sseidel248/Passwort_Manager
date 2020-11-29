unit PWCheck_PWM;

{******************************************************************************
Passwort Checker "KiiTree"

Author: Sebastian Seidel

Überprüft die Qualität des Passwortes
1 = sehr schwach
2 = schwach
3 = mäßig
4 = stark
5 = sehr stark

*******************************************************************************}

interface

type
  TPassworCheck = class
  strict private
    FPasswort : String;
    FResult : Integer;
  private
    constructor create( APassword : String );
    function CheckThis : Integer;
  public
    class function CheckMyPassword( APassword : String ) : Integer;
  end;

implementation

uses
  RegularExpressions;

{------------------------------------------------------------------------------
Author: Seidel 2020-11-18
-------------------------------------------------------------------------------}
class function TPassworCheck.CheckMyPassword( APassword : String ) : Integer;
var
PWCheck : TPassworCheck;
begin
  PWCheck := TPassworCheck.create( APassword );
  try
    Result := PWCheck.CheckThis;
  finally
    PWCheck.Free;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-11-18
-------------------------------------------------------------------------------}
constructor TPassworCheck.create( APassword : String );
begin
  FResult := 0;
  FPasswort := APassword;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-11-18
-------------------------------------------------------------------------------}
function TPassworCheck.CheckThis : Integer;
begin
  Result := 1;
  //prüfe ob das Passwort kleiner als 8 zeichen lang ist
  if length( Self.FPasswort ) < 8 then
    Exit                                 //max = 1
  else
    Inc( Result );

  //suche nach nur zahlen
  if TRegEx.IsMatch( FPasswort, '^[0-9]+$' ) then
    Exit                                  //max = 2
  else
  if TRegEx.IsMatch( FPasswort, '^[a-z]+$' ) then
    exit                                  //max = 2
  else
  if TRegEx.IsMatch( FPasswort, '^[A-Z]+$' ) then
    exit                                  //max = 2
  else
    Inc( Result );

  //suche nach nur Buchstaben
  if TRegEx.IsMatch( FPasswort, '^[a-zA-Z]+$' ) then
    Exit                                 //max = 3
  else
    Inc( Result );

  //suche nach Sonderzeichen
  if not TRegEx.IsMatch( FPasswort, '\W+' ) then
    Exit                                 //max = 4
  else
    Inc( Result );
end;

end.
