unit PersonServiceImplementation;

interface

uses
  System.Classes,
  System.SysUtils,
  System.JSON,
  System.DateUtils,

  Sparkle.HttpSys.Server,
  Sparkle.Security,

  XData.Server.Module,
  XData.Service.Common,
  XData.Sys.Exceptions,

  Bcl.Jose.Core.JWT,
  Bcl.Jose.Core.Builder,

  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  FireDAC.Comp.Client,
  FireDAC.Comp.BatchMove,
  FireDAC.Comp.BatchMove.Dataset,
  FireDAC.Comp.BatchMove.JSON,

  PersonService;

type
  [ServiceImplementation]
  TPersonService = class(TInterfacedObject, IPersonService)
  private
    function Directory(Format: String): TStream;
  end;

implementation

uses Unit1, Unit2, Unit3, TZDB;

function TPersonService.Directory(Format: String): TStream;
var
  DBConn: TFDConnection;
  Query1: TFDQuery;
  ClientTimeZone: TBundledTimeZone;
  ValidTimeZone: Boolean;
  ElapsedTime: TDateTime;
  User: IUserIdentity;
  JWT: String;
begin

  // Time this event
  ElapsedTime := Now;

  // Get data from the JWT
  User := TXDataOperationContext.Current.Request.User;
  JWT := TXDataOperationContext.Current.Request.Headers.Get('Authorization');
  if (User = nil) then raise EXDataHttpUnauthorized.Create('Missing authentication');

  // Setup DB connection and query
  try
    DBSupport.ConnectQuery(DBConn, Query1);
  except on E: Exception do
    begin
      MainForm.mmInfo.Lines.Add('['+E.Classname+'] '+E.Message);
      raise EXDataHttpUnauthorized.Create('Internal Error: CQ');
    end;
  end;

  // Check if we've got a valid JWT (one that has not been revoked)
  try
    {$Include sql\system\jwt_check\jwt_check.inc}
//    Mainform.mmInfo.Lines.Add(JWT);
//    mainform.mmInfo.lines.Add(DBSupport.HashThis(JWT));
//    Mainform.mmInfo.lines.add(DBSupport.HashThis('Bearer '+JWT));
    Query1.ParamByName('TOKENHASH').AsString := DBSupport.HashThis(JWT);
    Query1.Open;
  except on E: Exception do
    begin
      MainForm.mmInfo.Lines.Add('['+E.Classname+'] '+E.Message);
      raise EXDataHttpUnauthorized.Create('Internal Error: JC');
    end;
  end;
  if Query1.RecordCount <> 1 then raise EXDataHttpUnauthorized.Create('JWT was not validated');

  try
    {$Include sql\person\directory\directory.inc}
    Query1.Open;
  except on E: Exception do
    begin
      MainForm.mmInfo.Lines.Add('['+E.Classname+'] '+E.Message);
      raise EXDataHttpUnauthorized.Create('Internal Error: Directory');
    end;
  end;

  // Assuming Result is an uninitialized TStream
  DBSupport.Export(Format, Query1, Result);

end;


initialization
  RegisterServiceType(TPersonService);

end.
