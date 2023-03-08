unit DashboardServiceImplementation;

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

  DashboardService;

type
  [ServiceImplementation]
  TDashboardService = class(TInterfacedObject, IDashboardService)
  private
    function AdministratorDashboard: TStream;
  end;

implementation

uses Unit2, Unit3, TZDB;

function TDashboardService.AdministratorDashboard: TStream;
var
  DBConn: TFDConnection;
  Query1: TFDQuery;
  DatabaseName: String;
  DatabaseEngine: String;
  ElapsedTime: TDateTime;
  User: IUserIdentity;
  JWT: String;
  ResultJSON: TJSONObject;
  ResultArray: TJSONArray;
  Roles: TStringList;
  GotRole: Boolean;
  i: Integer;
begin
  // Returning JSON, so flag it as such
  TXDataOperationContext.Current.Response.Headers.SetValue('content-type', 'application/json');

  // Time this event
  ElapsedTime := Now;

  // Get data from the JWT
  User := TXDataOperationContext.Current.Request.User;
  JWT := TXDataOperationContext.Current.Request.Headers.Get('Authorization');
  if (User = nil) then raise EXDataHttpUnauthorized.Create('Missing authentication');

  // Setup DB connection and query
  try
    DatabaseName := User.Claims.Find('dbn').AsString;
    DatabaseEngine := User.Claims.Find('dbe').AsString;
    DBSupport.ConnectQuery(DBConn, Query1, DatabaseName, DatabaseEngine);
  except on E: Exception do
    begin
      MainForm.mmInfo.Lines.Add('['+E.Classname+'] '+E.Message);
      raise EXDataHttpUnauthorized.Create('Internal Error: CQ');
    end;
  end;

  // Check if we've got a valid JWT (one that has not been revoked)
  try
    {$Include sql\system\token_check\token_check.inc}
    Query1.ParamByName('TOKENHASH').AsString := DBSupport.HashThis(JWT);
    Query1.ParamByName('IPADDRESS').AsString := TXDataOperationContext.Current.Request.RemoteIP;
    Query1.Open;
  except on E: Exception do
    begin
      MainForm.mmInfo.Lines.Add('['+E.Classname+'] '+E.Message);
      raise EXDataHttpUnauthorized.Create('Internal Error: JC');
    end;
  end;
  if Query1.RecordCount <> 1 then raise EXDataHttpUnauthorized.Create('JWT was not validated');

  // Check if user has the Administrator role
  Roles := TStringList.Create;
  Roles.CommaText := User.Claims.Find('rol').AsString;
  i := 0;
  GotRole := False;
  while i < Roles.Count do
  begin
    if Roles[i] = '1' then GotRole := True;
    i := i + 1;
  end;
  Roles.Free;
  if not(GotRole) then raise EXDataHttpUnauthorized.Create('Missing Administrator Role');

  // Create object to be returned
  ResultJSON := TJSONObject.Create;

  // Get All Organization Info
  try
    {$Include sql\system\list_by_id\list_by_id.inc}
    Query1.ParamByName('LISTID').AsInteger := 2;
    Query1.Open;
  except on E: Exception do
    begin
      MainForm.mmInfo.Lines.Add('['+E.Classname+'] '+E.Message);
      raise EXDataHttpUnauthorized.Create('Internal Error: List By ID');
    end;
  end;
  ResultArray := TJSONObject.ParseJSONValue(DBSupport.QueryToJSON(Query1)) as TJSONArray;
  ResultJSON.AddPair('Organization', ResultArray);

  // Add photo
  try
    {$Include sql\person\photo\photo.inc}
    Query1.ParamByName('PERSONID').AsInteger :=  User.Claims.Find('usr').AsInteger;
    Query1.Open;
  except on E: Exception do
    begin
      MainForm.mmInfo.Lines.Add('['+E.Classname+'] '+E.Message);
      raise EXDataHttpUnauthorized.Create('Internal Error: Photo');
    end;
  end;
  ResultJSON.AddPair('Photo', String(Query1.FieldByName('photo_datauri').AsString));

  // Not sure if there is another version of this that is more direct?
  Result := TStringStream.Create(ResultJSON.ToString);

  // Cleanup
  ResultJSON.Free;

  // Keep track of endpoint history
  try
    {$Include sql\system\endpoint_history_insert\endpoint_history_insert.inc}
    Query1.ParamByName('PERSONID').AsInteger := User.Claims.Find('usr').AsInteger;
    Query1.ParamByName('ENDPOINT').AsString := 'DashboardService.AdministratorDashboard';
    Query1.ParamByName('ACCESSED').AsDateTime := TTimeZone.local.ToUniversalTime(ElapsedTime);
    Query1.ParamByName('IPADDRESS').AsString := TXDataOperationContext.Current.Request.RemoteIP;
    Query1.ParamByName('APPLICATION').AsString := User.Claims.Find('app').AsString;
    Query1.ParamByName('VERSION').AsString := MainForm.AppVersion;
    Query1.ParamByName('DATABASENAME').AsString := DatabaseName;
    Query1.ParamByName('DATABASEENGINE').AsString := DatabaseEngine;
    Query1.ParamByName('EXECUTIONMS').AsInteger := MillisecondsBetween(Now,ElapsedTime);
    Query1.ParamByName('DETAILS').AsString := '['+User.Claims.Find('anm').AsString+']';
    Query1.ExecSQL;
  except on E: Exception do
    begin
      MainForm.mmInfo.Lines.Add('['+E.Classname+'] '+E.Message);
      raise EXDataHttpUnauthorized.Create('Internal Error: EHI');
    end;
  end;

  // All Done
  try
    DBSupport.DisconnectQuery(DBConn, Query1);
  except on E: Exception do
    begin
      MainForm.mmInfo.Lines.Add('['+E.Classname+'] '+E.Message);
      raise EXDataHttpUnauthorized.Create('Internal Error: DQ');
    end;
  end;
end;



initialization
  RegisterServiceType(TDashboardService);

end.
