unit SystemServiceImplementation;

interface

uses
  System.Classes,
  System.SysUtils,
  System.JSON,
  System.DateUtils,

  XData.Server.Module,
  XData.Service.Common,
  XData.Sys.Exceptions,

  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  FireDAC.Comp.Client,
  FireDAC.Comp.BatchMove,
  FireDAC.Comp.BatchMove.Dataset,
  FireDAC.Comp.BatchMove.JSON,

  SystemService;

type
  [ServiceImplementation]
  TSystemService = class(TInterfacedObject, ISystemService)
  private

    function Info(TZ: String):TStream;
    function Login(Login_ID: String; Password: String; API_Key: String; TZ: String):String;

  end;

implementation

uses Unit2, Unit3, TZDB;

function TSystemService.Info(TZ: String):TStream;
var
  ResultJSON: TJSONObject;
  ServerIPArray: TJSONArray;
  ParametersArray: TJSONArray;
  ClientTimeZone: TBundledTimeZone;
  ValidTimeZone: Boolean;
begin
  // Returning JSON, so flag it as such
  TXDataOperationContext.Current.Response.Headers.SetValue('content-type', 'application/json');

  // Figure out if we have a valid TZ
  try
    ClientTimeZone := TBundledTimeZone.GetTimeZone(TZ);
    ValidTimeZone := True;
  except on E:Exception do
    begin
      if E.ClassName = 'ETimeZoneInvalid' then
      begin
        ValidTimeZone := False;
      end
      else
      begin
        ValidTimeZone := False;
        MainForm.mmInfo.Lines.Add('System Service Error: '+E.ClassName);
        MainForm.mmInfo.Lines.Add('System Service Error: '+E.Message);
      end;
    end;
  end;

  // Build our JSON Object
  ResultJSON := TJSONObject.Create;

  // This gets us a JSON Array of Parameters
  ParametersArray := TJSONObject.ParseJSONValue('['+Trim(MainForm.AppParameters.DelimitedText)+']') as TJSONArray;

  // This gets us a JSON Array of Server IP Addresses
  ServerIPArray := TJSONObject.ParseJSONValue('['+MainForm.IPAddresses.DelimitedText+']') as TJSONArray;

  ResultJSON.AddPair('Application Name',MainForm.AppName);
  ResultJSON.AddPair('Application Version',MainForm.AppVersion);
  ResultJSON.AddPair('Application Release',FormatDateTime('yyyy-mmm-dd (ddd) hh:nn:ss', MainForm.AppRelease));
  ResultJSON.AddPair('Application Release (UTC)',FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', MainForm.AppReleaseUTC));
  ResultJSON.AddPair('Application Parameters',ParametersArray);
  ResultJSON.AddPair('Application File Name',MainForm.AppFileName);
  ResultJSON.AddPair('Application File Size',TJSONNumber.Create(MainForm.AppFileSize));
  ResultJSON.AddPair('Application TimeZone',MainForm.AppTimeZone);
  ResultJSON.AddPair('Application TimeZone Offset',TJSONNumber.Create(MainForm.AppTimeZoneOffset));
  ResultJSON.AddPair('Application Memory',IntToStr(MainForm.GetMemoryUsage));
  ResultJSON.AddPair('IP Address (Server)',ServerIPArray);
  ResultJSON.AddPair('IP Address (Client)',TXDataOperationContext.Current.Request.RemoteIP);
  ResultJSON.AddPair('Current Time (Server)',FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now));
  ResultJSON.AddPair('Current Time (UTC)',FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', TTimeZone.Local.ToUniversalTime(Now)));
  if ValidTimeZone
  then ResultJSON.AddPair('Current Time (Client)',FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', ClientTimeZone.ToLocalTime(TTimeZone.Local.ToUniversalTime(Now))))
  else ResultJSON.AddPair('current Time (Client)','Invalid Client TimeZone');

  // Not sure if there is another version of this that is more direct?
  Result := TStringStream.Create(ResultJSON.ToString);

  // Cleanup
  TXDataOperationContext.Current.Handler.ManagedObjects.Add(Result);
  ResultJSON.Free;

// These are now part of ResultJSON and get freed when that gets freed
// ServerIPArray.Free;
// ParametersArray.Free;

end;



function TSystemService.Login(Login_ID, Password, API_Key, TZ: String): String;
var
  FDConn: TFDConnection;
  FDQuery1: TFDQuery;
  ClientTimeZone: TBundledTimeZone;
  ValidTimeZone: Boolean;
  ElapsedTime: TDateTime;
begin

  // Time this event
  ElapsedTime := Now;

  // Return 'Not Authenticated' until we've got a valid JWT to return
  Result := 'Not Authenticated';

  // Check that we've got values for all of the above.
  if Trim(Login_ID) = '' then raise EXDataHttpUnauthorized.Create('Login_ID cannot be blank');
  if Trim(Password) = '' then raise EXDataHttpUnauthorized.Create('Password cannot be blank');
  if Trim(API_Key) = '' then raise EXDataHttpUnauthorized.Create('API_Key cannot be blank');
  if Trim(TZ) = '' then raise EXDataHttpUnauthorized.Create('TZ cannot be blank');

  // Figure out if we have a valid TZ
  try
    ClientTimeZone := TBundledTimeZone.GetTimeZone(TZ);
    ValidTimeZone := True;
  except on E:Exception do
    begin
      if E.ClassName = 'ETimeZoneInvalid' then
      begin
        ValidTimeZone := False;
      end
      else
      begin
        ValidTimeZone := False;
        MainForm.mmInfo.Lines.Add('System Service Error: '+E.ClassName);
        MainForm.mmInfo.Lines.Add('System Service Error: '+E.Message);
      end;
    end;
  end;
  if not(ValidTimeZone) then raise EXDataHttpUnauthorized.Create('Invalid TZ');

  // Check if we've got a valid API_Key
  DBSupport.ConnectQuery(FDConn, FDQuery1);
  {$Include sql/system/api_key_check_sqlite.inc}
  FDQuery1.ParamByName('APIKEY').AsString := API_Key;
  FDQuery1.Open;
  if FDQuery1.RecordCount = 0 then raise EXDataHttpUnauthorized.Create('API_Key was not validated');

  // Check if the IP Address is always allowed
  {$Include sql/system/ip_allow_check_sqlite.inc}
  FDQuery1.ParamByName('IPADDRESS').AsString := TXDataOperationContext.Current.Request.RemoteIP;
  FDQuery1.Open;
  if FDQuery1.RecordCount = 0 then
  begin
    {$Include sql/system/ip_block_check_sqlite.inc}
    FDQuery1.ParamByName('IPADDRESS').AsString := TXDataOperationContext.Current.Request.RemoteIP;
    FDQuery1.Open;
    if FDQuery1.RecordCount > 0 then raise EXDataHttpUnauthorized.Create('IP Address has been temporarily blocked')
  end;

  // IP Check passed.  Next up: Login attempts.  First we log the attempt.  Then we count them.
  {$Include sql/system/login_fail_insert_sqlite.inc}
  FDQuery1.ParamByName('LOGINID').AsString := Login_ID;
  FDQuery1.ParamByName('IPADDRESS').AsString := TXDataOperationContext.Current.Request.RemoteIP;
  FDQuery1.Execute;
  {$Include sql/system/login_fail_check_sqlite.inc}
  FDQuery1.ParamByName('LOGINID').AsString := Login_ID;
  FDQuery1.ParamByName('IPADDRESS').AsString := TXDataOperationContext.Current.Request.RemoteIP;
  FDQuery1.Open;
  if FDQuery1.FieldByNAme('attempts').AsInteger >= 5 then
  begin
    {$Include sql/system/ip_block_insert_sqlite.inc}
    FDQuery1.ParamByName('IPADDRESS').AsString := TXDataOperationContext.Current.Request.RemoteIP;
    FDQuery1.ParamByName('REASON').AsString := 'Too many failed login attempts.';
    FDQuery1.ExecSQL;
    raise EXDataHttpUnauthorized.Create('Too many failed login attempts.  Please try again later.')
  end;

  // Alright, the login has passed all its initial checks.  Lets see if the Login_ID is known




end;

initialization
  RegisterServiceType(TSystemService);

end.
