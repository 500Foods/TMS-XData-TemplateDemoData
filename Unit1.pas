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
    DBConn: TFDConnection;
    Query1: TFDQuery;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    procedure DataModuleCreate(Sender: TObject);
    public
      DatabaseName: String;
      DatabaseEngine: String;
      DatabaseUsername: String;
      DatabasePassword: String;
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

  // FDConnection component dropped on form - DBConn
  // FDPhysSQLiteDriverLink component droppoed on form
  // FDQuery component dropped on form - Query1
  // DatabaseName is a Form Variable
  // DatabaseEngine is a Form Variable
  // DatabaseUsername is a Form Variable
  // DatabasePassword is a Form Variable

  DatabaseEngine := 'sqlite';
  DatabaseName := 'DemoData.sqlite';
  DatabaseUsername := 'dbuser';
  DatabasePassword := 'dbpass';

  i := 1;
  while i <= ParamCount do
  begin
    if Pos('DBNAME=',Uppercase(ParamStr(i))) = 1
    then DatabaseName := Copy(ParamStr(i),8,length(ParamStr(i)));

    if Pos('DBENGINE=',Uppercase(ParamStr(i))) = 1
    then DatabaseEngine := Copy(ParamStr(i),10,length(ParamStr(i)));

    if Pos('DBUSER=',Uppercase(ParamStr(i))) = 1
    then DatabaseUsername := Copy(ParamStr(i),8,length(ParamStr(i)));

    if Pos('DBPASS=',Uppercase(ParamStr(i))) = 1
    then DatabasePassword := Copy(ParamStr(i),8,length(ParamStr(i)));

    i := i + 1;
  end;

  FDManager.Open;
  DBConn.Params.Clear;

  if (DatabaseEngine = 'sqlite') then
  begin
    // This creates the database if it doesn't already exist
    DBConn.Params.DriverID := 'SQLite';
    DBConn.Params.Database := DatabaseName;
    DBConn.Params.Add('DateTimeFormat=String');
    DBConn.Params.Add('Synchronous=Full');
    DBConn.Params.Add('LockingMode=Normal');
    DBConn.Params.Add('SharedCache=False');
    DBConn.Params.Add('UpdateOptions.LockWait=True');
    DBConn.Params.Add('BusyTimeout=10000');
    DBConn.Params.Add('SQLiteAdvanced=page_size=4096');
    // Extras
    DBConn.FormatOptions.StrsEmpty2Null := True;
    with DBConn.FormatOptions do
    begin
      StrsEmpty2Null := true;
      OwnMapRules := True;
      with MapRules.Add do begin
        SourceDataType := dtWideMemo;
        TargetDataType := dtWideString;
      end;

    end;
  end;

  DBConn.Open;
  Query1.Connection := DBConn;

  // Create and populate tables
  {$Include ddl\person\person.inc}
  {$Include ddl\role\role.inc}
  {$Include ddl\person_role\person_role.inc}
  {$Include ddl\api_key\api_key.inc}
  {$Include ddl\token\token.inc}
  {$Include ddl\ip_allow\ip_allow.inc}
  {$Include ddl\ip_block\ip_block.inc}
  {$Include ddl\login_fail\login_fail.inc}
  {$Include ddl\contact\contact.inc}
  {$Include ddl\list\list.inc}
  {$Include ddl\login_history\login_history.inc}
  {$Include ddl\endpoint_history\endpoint_history.inc}


end;

end.
