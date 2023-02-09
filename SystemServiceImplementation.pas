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

  Bcl.Jose.Core.JWT,
  Bcl.Jose.Core.Builder,

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

uses Unit1, Unit2, Unit3, TZDB;

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

  PersonID: Integer;
  Roles: String;
  EMailAddress: String;
  PasswordHash: String;

  JWT: TJWT;
  IssuedAt: TDateTime;
  ExpiresAt: TDateTime;

begin

  // Time this event
  ElapsedTime := Now;

  // We're creating a JWT now that is valid for 15 minutes
  IssuedAt := Now;
  ExpiresAt := IncMinute(IssuedAt,15);

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

  // Setup DB connection and query
  DBSupport.ConnectQuery(FDConn, FDQuery1);

  // Check if we've got a valid API_Key
  {$Include sql\system\api_key_check\api_key_check.inc}
  FDQuery1.ParamByName('APIKEY').AsString := LowerCase(API_Key);
  FDQuery1.Open;
  if FDQuery1.RecordCount = 0 then raise EXDataHttpUnauthorized.Create('API_Key was not validated');

  // Check if the IP Address is always allowed
  {$Include sql\system\ip_allow_check\ip_allow_check.inc}
  FDQuery1.ParamByName('IPADDRESS').AsString := TXDataOperationContext.Current.Request.RemoteIP;
  FDQuery1.Open;
  if FDQuery1.RecordCount = 0 then
  begin
    {$Include sql\system\ip_block_check\ip_block_check.inc}
    FDQuery1.ParamByName('IPADDRESS').AsString := TXDataOperationContext.Current.Request.RemoteIP;
    FDQuery1.Open;
    if FDQuery1.RecordCount > 0 then raise EXDataHttpUnauthorized.Create('IP Address has been temporarily blocked')
  end;

  // IP Check passed.  Next up: Login attempts.  First we log the attempt.  Then we count them.
  {$Include sql\system\login_fail_insert\login_fail_insert.inc}
  FDQuery1.ParamByName('LOGINID').AsString := LowerCase(Login_ID);
  FDQuery1.ParamByName('IPADDRESS').AsString := TXDataOperationContext.Current.Request.RemoteIP;
  FDQuery1.Execute;
  {$Include sql\system\login_fail_check\login_fail_check.inc}
  FDQuery1.ParamByName('LOGINID').AsString := LowerCase(Login_ID);
  FDQuery1.ParamByName('IPADDRESS').AsString := TXDataOperationContext.Current.Request.RemoteIP;
  FDQuery1.Open;
  if FDQuery1.FieldByNAme('attempts').AsInteger >= 5 then
  begin
    {$Include sql\system\ip_block_insert\ip_block_insert.inc}
    FDQuery1.ParamByName('IPADDRESS').AsString := TXDataOperationContext.Current.Request.RemoteIP;
    FDQuery1.ParamByName('REASON').AsString := 'Too many failed login attempts.';
    FDQuery1.ExecSQL;
    raise EXDataHttpUnauthorized.Create('Too many failed login attempts.  Please try again later.')
  end;

  // Alright, the login has passed all its initial checks.  Lets see if the Login_ID is known
  {$Include sql\system\contact_search\contact_search.inc}
  FDQuery1.ParamByName('LOGINID').AsString := LowerCase(Login_ID);
  FDQuery1.Open;
  if FDQuery1.RecordCount = 0
  then raise EXDataHttpUnauthorized.Create('Login not authenticated: invalid login')
  else if FDQuery1.RecordCount > 1
       then EXDataHttpUnauthorized.Create('Login not authenticated: ambiguous login');

  // Got the Person ID
  PersonID := FDQuery1.FieldByName('person_id').AsInteger;

  // Ok, we've got a person, let's see if they've got the required Login role
  {$Include sql\system\person_role_check\person_role_check.inc}
  FDQuery1.ParamByName('PERSONID').AsInteger := PersonID;
  FDQuery1.Open;
  if FDQuery1.FieldByName('role_id').AsInteger <> 0 then raise EXDataHttpUnauthorized.Create('Login not authorized');

  // Login role is present, so let's make a note of the other roles
  Roles := '';
  while not(FDQuery1.EOF) do
  begin
    Roles := Roles + FDQuery1.FieldByName('role_id').AsString;
    FDquery1.Next;
    if not(FDQuery1.EOF) then Roles := Roles + ',';
  end;

  // Get the first available EMail address if possible
  EMailAddress := 'unavailable';
  {$Include sql\system\contact_email\contact_email.inc}
  FDQuery1.ParamByName('PERSONID').AsInteger := PersonID;
  FDQuery1.Open;
  if FDQuery1.RecordCount > 0
  then EMailAddress := FDQuery1.FieldByName('value').AsString;


  // Finally, let's check the actual passowrd.
  PasswordHash := DBSupport.HashThis('XData-Password:'+Trim(Password));
  {$Include sql\system\person_password_check\person_password_check.inc}
  FDQuery1.ParamByName('PERSONID').AsInteger := PersonID;
  FDQuery1.ParamByName('PASSWORDHASH').AsString := PasswordHash;
  FDQuery1.Open;
  if FDQuery1.RecordCount <> 1 then raise EXDataHttpUnauthorized.Create('Login not authenticated: invalid password');

  // Login has been authenticated and authorized.

  // Generate a new JWT
  JWT := TJWT.Create;
  try
    // Setup some Claims
    JWT.Claims.Issuer := MainForm.AppName;
    JWT.Claims.SetClaimOfType<string>( 'ver', MainForm.AppVersion );
    JWT.Claims.SetClaimOfType<string>( 'tzn', TZ );
    JWT.Claims.SetClaimOfType<integer>('usr', PersonID );
    JWT.Claims.SetClaimOfType<string>( 'rol', Roles );
    JWT.Claims.SetClaimOfType<string>( 'eml', EMailAddress );
    JWT.Claims.SetClaimOfType<string>( 'fnm', FDQuery1.FieldByName('first_name').AsString );
    JWT.Claims.SetClaimOfType<string>( 'mnm', FDQuery1.FieldByName('middle_name').AsString );
    JWT.Claims.SetClaimOfType<string>( 'lnm', FDQuery1.FieldByName('last_name').AsString );
    JWT.Claims.SetClaimOfType<string>( 'anm', FDQuery1.FieldByName('account_name').AsString );
    JWT.Claims.SetClaimOfType<string>( 'net', TXDataOperationContext.Current.Request.RemoteIP );
    JWT.Claims.SetClaimOfType<string>( 'iat', FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', IssuedAt));
    JWT.Claims.SetClaimOfType<string>( 'eat', FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', ExpiresAt));
    JWT.Claims.Expiration := ExpiresAt;

    // Generate the actual JWT
    Result := TJOSE.SHA256CompactToken(ServerContainer.XDataServerJWT.Secret, JWT);
    Result := 'Bearer '+Result;
  finally
    JWT.Free;
  end;

  // Add the JWT to a table that we'll use to help with expring tokens
  {$Include sql\system\token_insert\token_insert.inc}
  FDQuery1.ParamByName('TOKENHASH').AsString := DBSupport.HashThis(Result);
  FDQuery1.ParamByName('VALIDAFTER').AsDateTime := IssuedAt;
  FDQuery1.ParamByName('VALIDUNTIL').AsDateTime := ExpiresAt;
  FDQuery1.ParamByName('PERSONID').AsInteger := PersonID;
  FDQuery1.ExecSQL;

  // Keep track of login history
  {$Include sql\system\login_history_insert\login_history_insert.inc}
  FDQuery1.ParamByName('LOGGEDIN').AsDateTime := IssuedAt;
  FDQuery1.ParamByName('IPADDRESS').AsString := TXDataOperationContext.Current.Request.RemoteIP;
  FDQuery1.ParamByName('PERSONID').AsInteger := PersonID;
  FDQuery1.ExecSQL;

  // Cleanup after login
  {$Include sql\system\login_cleanup\login_cleanup.inc}
  FDQuery1.ParamByName('IPADDRESS').AsString := TXDataOperationContext.Current.Request.RemoteIP;
  FDQuery1.ParamByName('LOGINID').AsString := LowerCase(Login_ID);
  FDQuery1.ExecSQL;

  // Keep track of endpoint history
  {$Include sql\system\endpoint_history_insert\endpoint_history_insert.inc}
  FDQuery1.ParamByName('ENDPOINT').AsString := 'SystemService.Login';
  FDQuery1.ParamByName('ACCESSED').AsDateTime := ElapsedTime;
  FDQuery1.ParamByName('IPADDRESS').AsString := TXDataOperationContext.Current.Request.RemoteIP;
  FDQuery1.ParamByName('EXECUTIONMS').AsInteger := MillisecondsBetween(Now,ElapsedTime);
  FDQuery1.ParamByName('DETAILS').AsString := '['+Login_ID+'] [Passowrd] [API_Key] ['+TZ+']';
  FDQuery1.ExecSQL;

  // All Done
  DBSupport.CleanupQuery(FDConn, FDQuery1);

end;

initialization
  RegisterServiceType(TSystemService);

end.
