unit Unit1;

interface

uses
  System.SysUtils, System.Classes, Sparkle.HttpServer.Module,
  Sparkle.HttpServer.Context, Sparkle.Comp.Server,
  Sparkle.Comp.HttpSysDispatcher, Aurelius.Drivers.Interfaces,
  Aurelius.Comp.Connection, XData.Comp.ConnectionPool, XData.Server.Module,
  XData.Comp.Server, Sparkle.Comp.CorsMiddleware,
  Sparkle.Comp.CompressMiddleware, Sparkle.Comp.JwtMiddleware, XData.Aurelius.ModelBuilder,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteDef, FireDAC.Phys.SQLite, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TServerContainer = class(TDataModule)
    SparkleHttpSysDispatcher: TSparkleHttpSysDispatcher;
    XDataServer: TXDataServer;
    XDataConnectionPool: TXDataConnectionPool;
    AureliusConnection: TAureliusConnection;
    XDataServerJWT: TSparkleJwtMiddleware;
    XDataServerCompress: TSparkleCompressMiddleware;
    XDataServerCORS: TSparkleCorsMiddleware;
    FDConnection1: TFDConnection;
    FDQuery1: TFDQuery;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    procedure DataModuleCreate(Sender: TObject);
    public
      DatabaseName: String;
  end;

var
  ServerContainer: TServerContainer;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TServerContainer.DataModuleCreate(Sender: TObject);
var
  i: Integer;
begin
  // Setup Swagger Header
  TXDataModelBuilder.LoadXMLDoc(XDataServer.Model);
  XDataServer.Model.Title := 'XData Template Demo API';
  XDataServer.Model.Version := '1.0';
  XDataServer.Model.Description :=
    '### Overview'#13#10 +
    'This is the REST API for interacting with the XData Template Demo.';

  // FDConnection component dropped on form
  // FDPhysSQLiteDriverLink component droppoed on form
  // FDQuery component dropped on form
  // DatabaseName is a Form Variable


  // Use a different database if one is passed as a parameter
  DatabaseName := 'DemoData.sqlite';
  i := 1;
  while i <= ParamCount do
  begin
    if Pos('DB=',Uppercase(ParamStr(i))) = 1 then
    begin
      DatabaseName := Copy(ParamStr(i),4,length(ParamStr(i)));
    end;
    i := i + 1;
  end;


  // This creates the database if it doesn't already exist
  FDManager.Open;
  FDConnection1.Params.Clear;
  FDConnection1.Params.DriverID := 'SQLite';
  FDConnection1.Params.Database := DatabaseName;
  FDConnection1.Params.Add('Synchronous=Full');
  FDConnection1.Params.Add('LockingMode=Normal');
  FDConnection1.Params.Add('SharedCache=False');
  FDConnection1.Params.Add('UpdateOptions.LockWait=True');
  FDConnection1.Params.Add('BusyTimeout=10000');
  FDConnection1.Params.Add('SQLiteAdvanced=page_size=4096');
  FDConnection1.Open;


end;

end.
