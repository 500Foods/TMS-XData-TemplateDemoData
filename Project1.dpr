program Project1;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {ServerContainer: TDataModule},
  Unit2 in 'Unit2.pas' {MainForm},
  SystemService in 'SystemService.pas',
  SystemServiceImplementation in 'SystemServiceImplementation.pas',
  TZDB in 'TZDB.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'TMS XData Template Demo Data';
  Application.CreateForm(TServerContainer, ServerContainer);
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
