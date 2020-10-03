unit Login_PWM_Test;

{******************************************************************************
Login Test des Login Dialoges von "KiiTree"
Author: Sebastian Seidel
Date: 2020-09-27
*******************************************************************************}

interface
uses
  DUnitX.TestFramework, Global_PWM, Login_PWM, Vcl.Forms;

type

  [TestFixture]
  TMyLoginTest = class(TObject)
  public
    fForm: TLogin;
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    [Testcase( 'Normaler Login User existiert', '1,1,false,1')]
    [Testcase( 'Normaler Login Passwort falsch', '1,2,false,8')]
    [Testcase( 'Neuer User existiert bereits' , '1,1,true,6')]
    procedure LoginTest( User , Passwort : String; CB_Checked : Boolean; Result : Integer );
    [Test]
    [Testcase( 'User existiert noch nicht kann angelegt werden', '2,2,false,4')]
    [Testcase( 'Neuer User soll erstellt werden' , '1,1,true,4')]
    procedure LoginTestNewUser( User , Passwort : String; CB_Checked : Boolean; Result : Integer );
  end;

{
  mrYes 	      = 6
  mrNo 	        = 7
  mrOK 	        = 1
  mrCancel     	= 2
  mrAbort 	    = 3
  mrRetry 	    = 4
  mrIgnore 	    = 5
  mrAll 	      = 8
  mrNoToAll 	  = 9
  mrYesToAll 	  = 10

  Test hier mit Username = Passwort
}


const
  Test_Folder_Out = 'D:\Delphi embarcadero\Passwort_Manager\Tests\PM_DB\';

var
  Savefile : String;

implementation

uses
  ShellAPI, Windows,  System.Classes,Vcl.StdCtrls;

function DeleteFiles(const AFile: string): boolean;
var
  sh: SHFileOpStruct;
begin
  ZeroMemory(@sh, SizeOf(sh));
  with sh do
  begin
    Wnd := Application.Handle;
    wFunc := FO_DELETE;
    pFrom := PChar(AFile +#0);
    fFlags := FOF_SILENT or FOF_NOCONFIRMATION;
  end;
  result := SHFileOperation(sh) = 0;
end;

procedure TMyLoginTest.LoginTest(User: string; Passwort: string; CB_Checked : Boolean; Result : Integer);
var
txt : TStringlist;
begin
  {$DEFINE TESTLOGIN}
  fForm.UsernameEdit.text := User;
  fForm.UserMasterPWEdit.text := Passwort;
  fForm.CBNewUser.Checked := CB_Checked;

  //PseudoNutzer Datei erstellt
  txt := TStringList.Create;
  try
    saveFile := Test_Folder_Out + MD5String( User ) + '.PMPK';
    txt.SaveToFile( savefile );
  finally
    txt.Free;
  end;
   //PseudoNutzer Datei erstellt - ende -

  fForm.AnmeldeBtnClick( nil );

  Assert.AreEqual( Result, fForm.ModalResult, 'Test mit bereits bestehen User nicht erfolgreich.' );
  {$UNDEF TESTLOGIN}
end;

procedure TMyLoginTest.LoginTestNewUser( User , Passwort : String; CB_Checked : Boolean; Result : Integer );
begin
  {$DEFINE TESTLOGIN}
  fForm.UsernameEdit.text := User;
  fForm.UserMasterPWEdit.text := Passwort;
  fForm.CBNewUser.Checked := CB_Checked;
  fForm.AnmeldeBtnClick( nil );

  Assert.AreEqual( Result, fForm.ModalResult, 'Test mit bereits bestehen User nicht erfolgreich.' );
  {$UNDEF TESTLOGIN}
end;

procedure TMyLoginTest.Setup;  //jedesmal vor dem Test
begin
  fForm := TLogin.Create( nil );
end;

procedure TMyLoginTest.TearDown;
begin
  DeleteFiles( Savefile );
  fForm.Free;
end;


initialization
  TDUnitX.RegisterTestFixture(TMyLoginTest);
end.
