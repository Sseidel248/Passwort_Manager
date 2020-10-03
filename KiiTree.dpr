program KiiTree;

uses
  Vcl.Forms,
  Main_PWM in 'Main_PWM.pas' {Main},
  PWM_VST in 'PWM_VST.pas',
  Login_PWM in 'Login_PWM.pas' {Login},
  Global_PWM in 'Global_PWM.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMain, Main);
  Application.CreateForm(TLogin, Login);
  Application.Run;
end.
