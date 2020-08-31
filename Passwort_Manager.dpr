program Passwort_Manager;

uses
  Vcl.Forms,
  Main_PWM in 'Main_PWM.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
