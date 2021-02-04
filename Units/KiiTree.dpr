program KiiTree;

uses
  Vcl.Forms,
  Main_PWM in 'Main_PWM.pas' {Main},
  PWM_VST in 'PWM_VST.pas',
  Login_PWM in 'Login_PWM.pas' {Login},
  Global_PWM in 'Global_PWM.pas',
  About_PWM in 'About_PWM.pas' {About_Dlg},
  MPW_Change_PWM in 'MPW_Change_PWM.pas' {MasterPasswortChange},
  PWCheck_PWM in 'PWCheck_PWM.pas',
  InstanceCheck in 'InstanceCheck.pas',
  OneInstance in 'OneInstance.pas',
  Messages_PWM in 'Messages_PWM.pas';

//Change: Seidel 2021-01-26 Immer nur eine Instance darf offen sein (KT-59)
procedure NewInstance(ProcessId: Cardinal; CmdLine: String; var Allow: Boolean);
begin
  Allow := FALSE;
end;

{$R *.res}

begin
  NewInstProc := NewInstance;
  Application.Initialize;
//  Application.MainFormOnTaskbar := true;//Change: Seidel 2021-01-30
//  Application.CreateForm(TLogin, Login);
  Application.CreateForm(TMain, Main);
//    Application.CreateForm(TLogin, Login);
//  Application.CreateForm(TAbout_Dlg, About_Dlg);//Change: Seidel 2021-02-03
//  Application.CreateForm(TMasterPasswortChange, MasterPasswortChange);
  Application.Run;
end.
