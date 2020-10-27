program KiiTree;

uses
  Vcl.Forms,
  Main_PWM in 'Main_PWM.pas' {Main},
  PWM_VST in 'PWM_VST.pas',
  Login_PWM in 'Login_PWM.pas' {Login},
  Global_PWM in 'Global_PWM.pas',
  About_PWM in 'About_PWM.pas' {About_Dlg},
  MPW_Change_PWM in 'MPW_Change_PWM.pas' {MasterPasswortChange};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMain, Main);
  Application.CreateForm(TLogin, Login);
  Application.CreateForm(TAbout_Dlg, About_Dlg);
  Application.CreateForm(TMasterPasswortChange, MasterPasswortChange);
  Application.Run;
end.
