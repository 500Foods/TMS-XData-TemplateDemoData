program XDataServer;

uses
  Vcl.Forms,
  Unit1 in 'units\Unit1.pas' {ServerContainer: TDataModule},
  Unit2 in 'units\Unit2.pas' {MainForm},
  Unit3 in 'units\Unit3.pas' {DBSupport: TDataModule},
  SystemService in 'units\SystemService.pas',
  SystemServiceImplementation in 'units\SystemServiceImplementation.pas',
  TZDB in 'TZDB.pas',
  PersonService in 'units\PersonService.pas',
  PersonServiceImplementation in 'units\PersonServiceImplementation.pas',
  DashboardService in 'units\DashboardService.pas',
  DashboardServiceImplementation in 'units\DashboardServiceImplementation.pas',
  ChatService in 'units\ChatService.pas',
  ChatServiceImplementation in 'units\ChatServiceImplementation.pas',
  MessagingService in 'units\MessagingService.pas',
  MessagingServiceImplementation in 'units\MessagingServiceImplementation.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'TMS XData Template Demo Data';
  Application.CreateForm(TServerContainer, ServerContainer);
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TDBSupport, DBSupport);
  Application.Run;
end.
