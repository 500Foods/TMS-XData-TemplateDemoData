unit SystemServiceImplementation;

interface

uses
  System.Classes,
  System.SysUtils,
  System.JSON,
  System.DateUtils,

  System.Generics.Collections,

  System.Net.URLClient,
  System.Net.HttpClientComponent,
  System.Net.HttpClient,

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

  SystemService;

type
  [ServiceImplementation]
  TSystemService = class(TInterfacedObject, ISystemService)
  private

    function Info(TZ: String):TStream;
    function Login(Login_ID: String; Password: String; API_Key: String; TZ: String):TStream;
    function Logout(ActionSession: String; ActionLog: String):TStream;
    function Renew(ActionSession: String; ActionLog: String):TStream;

    function AvailableIconSets:TStream;
    function SearchIconSets(SearchTerms: String; SearchSets:String; Results:Integer):TStream;
    function SearchFontAwesome(Query: String):TStream;

  end;

implementation

uses Unit1, Unit2, Unit3, TZDB;

const
//  JWT_PERIOD = 2;  // How long a JWT is valid for, in minutes
  JWT_PERIOD = 15;  // How long a JWT is valid for, in minutes

function TSystemService.AvailableIconSets: TStream;
begin
  // Returning JSON, so flag it as such
  TXDataOperationContext.Current.Response.Headers.SetValue('content-type', 'application/json');

  Result := TStringStream.Create(MainForm.AppIconSets);
end;

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
  ClientTimeZone := TBundledTimeZone.GetTimeZone('America/Vancouver');
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
  ServerIPArray := TJSONObject.ParseJSONValue('['+StringReplace(MainForm.IPAddresses.DelimitedText,'  ',' ',[rfReplaceAll])+']') as TJSONArray;


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
  if ValidTimeZone and Assigned(ClientTimeZone)
  then ResultJSON.AddPair('Current Time (Client)',FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', ClientTimeZone.ToLocalTime(TTimeZone.Local.ToUniversalTime(Now))))
  else ResultJSON.AddPair('current Time (Client)','Invalid Client TimeZone');

  // Not sure if there is another version of this that is more direct?
  Result := TStringStream.Create(ResultJSON.ToString);

  // Cleanup
  ResultJSON.Free;

  // These are now part of ResultJSON and get freed when that gets freed
// ServerIPArray.Free;
// ParametersArray.Free;

end;



function TSystemService.Login(Login_ID, Password, API_Key, TZ: String): TStream;
var
  DBConn: TFDConnection;
  Query1: TFDQuery;
  DatabaseEngine: String;
  DatabaseName: String;
  ClientTimeZone: TBundledTimeZone;
  ValidTimeZone: Boolean;
  ElapsedTime: TDateTime;

  PersonID: Integer;
  ApplicationName: String;
  Roles: String;
  EMailAddress: String;
  PasswordHash: String;

  JWT: TJWT;
  JWTString: String;
  IssuedAt: TDateTime;
  ExpiresAt: TDateTime;
//  DStr: String;
//  DDate: TDateTime;

begin
  // Returning JWT, so flag it as such
  TXDataOperationContext.Current.Response.Headers.SetValue('content-type', 'application/jwt');

  // Time this event
  ElapsedTime := Now;

  // We're creating a JWT now that is valid for JWT_PERIOD minutes
  IssuedAt := Now;
  ExpiresAt := IncMinute(IssuedAt, JWT_PERIOD);

  // Check that we've got values for all of the above.
  if Trim(Login_ID) = '' then raise EXDataHttpUnauthorized.Create('Username cannot be blank.');
  if Trim(Password) = '' then raise EXDataHttpUnauthorized.Create('Password cannot be blank.');
  if Trim(API_Key) = '' then raise EXDataHttpUnauthorized.Create('API Key cannot be blank.');
  if Trim(TZ) = '' then raise EXDataHttpUnauthorized.Create('Timezone cannot be blank.');

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
  if not(ValidTimeZone) then raise EXDataHttpUnauthorized.Create('Invalid Timezone.');

  // Setup DB connection and query
  DatabaseName := MainForm.DatabaseName;
  DatabaseEngine := MainForm.DatabaseEngine;
  try
    DBSupport.ConnectQuery(DBConn, Query1, DatabaseName, DatabaseEngine);
  except on E: Exception do
    begin
      DBSupport.DisconnectQuery(DBConn, Query1);
      MainForm.mmInfo.Lines.Add('['+E.Classname+'] '+E.Message);
      raise EXDataHttpUnauthorized.Create('Internal Error: CQ');
    end;
  end;

  // Check if we've got a valid API_Key
  try
    {$Include sql\system\api_key_check\api_key_check.inc}
    Query1.ParamByName('APIKEY').AsString := LowerCase(API_Key);
    Query1.Open;
  except on E: Exception do
    begin
      DBSupport.DisconnectQuery(DBConn, Query1);
      MainForm.mmInfo.Lines.Add('['+E.Classname+'] '+E.Message);
      raise EXDataHttpUnauthorized.Create('Internal Error: AKC');
    end;
  end;
  if Query1.RecordCount = 0 then
  begin
    DBSupport.DisconnectQuery(DBConn, Query1);
    raise EXDataHttpUnauthorized.Create('API_Key was not validated.');
  end;
  ApplicationName := Query1.FieldByName('application').AsString;

  // Invalid Date Conversin???
//  DStr := Query1.FieldByName('valid_until').AsString;
//  DDate := EncodeDateTime(
//    StrToInt(Copy(DStr,1,4)),
//    StrToInt(Copy(DStr,6,2)),
//    StrToInt(Copy(DStr,9,2)),
//    StrToInt(Copy(DStr,12,2)),
//    StrToInt(Copy(DStr,15,2)),
//    StrToInt(Copy(DStr,18,2)),
//    0
//  );
//  if not(Query1.FieldByName('valid_until').IsNull) and
//     (ExpiresAt > TTimeZone.Local.ToLocalTime(DDate))
//  then ExpiresAt := TTimeZone.Local.ToLocalTime(DDate);

  if not(Query1.FieldByName('valid_until').IsNull) and
     (ExpiresAt > TTimeZone.Local.ToLocalTime(Query1.FieldByName('valid_until').AsDateTime))
  then ExpiresAt := TTimeZone.Local.ToLocalTime(Query1.FieldByName('valid_until').AsDateTime);

  // Check if the IP Address is always allowed
  try
    {$Include sql\system\ip_allow_check\ip_allow_check.inc}
    Query1.ParamByName('IPADDRESS').AsString := TXDataOperationContext.Current.Request.RemoteIP;
    Query1.Open;
    if Query1.RecordCount = 0 then
    begin
      try
        {$Include sql\system\ip_block_check\ip_block_check.inc}
        Query1.ParamByName('IPADDRESS').AsString := TXDataOperationContext.Current.Request.RemoteIP;
        Query1.Open;
        if Query1.RecordCount > 0 then raise EXDataHttpUnauthorized.Create('IP Address has been blocked temporarily.')
      except on E: Exception do
        begin
    DBSupport.DisconnectQuery(DBConn, Query1);
          MainForm.mmInfo.Lines.Add('['+E.Classname+'] '+E.Message);
          raise EXDataHttpUnauthorized.Create('Internal Error: IBC');
        end;
      end;
    end;
  except on E: Exception do
    begin
      DBSupport.DisconnectQuery(DBConn, Query1);
      MainForm.mmInfo.Lines.Add('['+E.Classname+'] '+E.Message);
      raise EXDataHttpUnauthorized.Create('Internal Error: IAC');
    end;
  end;

  // IP Check passed.  Next up: Login attempts.  First we log the attempt.  Then we count them.
  try
    {$Include sql\system\login_fail_insert\login_fail_insert.inc}
    Query1.ParamByName('LOGINID').AsString := LowerCase(Login_ID);
    Query1.ParamByName('IPADDRESS').AsString := TXDataOperationContext.Current.Request.RemoteIP;
    Query1.Execute;
  except on E: Exception do
    begin
      DBSupport.DisconnectQuery(DBConn, Query1);
      MainForm.mmInfo.Lines.Add('['+E.Classname+'] '+E.Message);
      raise EXDataHttpUnauthorized.Create('Internal Error: LFI');
    end;
  end;
  try
    {$Include sql\system\login_fail_check\login_fail_check.inc}
    Query1.ParamByName('LOGINID').AsString := LowerCase(Login_ID);
    Query1.ParamByName('IPADDRESS').AsString := TXDataOperationContext.Current.Request.RemoteIP;
    Query1.Open;
  except on E: Exception do
    begin
      DBSupport.DisconnectQuery(DBConn, Query1);
      MainForm.mmInfo.Lines.Add('['+E.Classname+'] '+E.Message);
      raise EXDataHttpUnauthorized.Create('Internal Error: LFC');
    end;
  end;
  if Query1.FieldByNAme('attempts').AsInteger >= 5 then
  begin
    try
      {$Include sql\system\ip_block_insert\ip_block_insert.inc}
      Query1.ParamByName('IPADDRESS').AsString := TXDataOperationContext.Current.Request.RemoteIP;
      Query1.ParamByName('REASON').AsString := 'Too many failed login attempts.';
      Query1.ExecSQL;
    except on E: Exception do
      begin
        DBSupport.DisconnectQuery(DBConn, Query1);
        MainForm.mmInfo.Lines.Add('['+E.Classname+'] '+E.Message);
        raise EXDataHttpUnauthorized.Create('Internal Error: IBI');
      end;
    end;
    raise EXDataHttpUnauthorized.Create('Too many failed login attempts.  Please try again later.')
  end;

  // Alright, the login has passed all its initial checks.  Lets see if the Login_ID is known
  try
    {$Include sql\system\contact_search\contact_search.inc}
    Query1.ParamByName('LOGINID').AsString := LowerCase(Login_ID);
    Query1.Open;
  except on E: Exception do
    begin
      DBSupport.DisconnectQuery(DBConn, Query1);
      MainForm.mmInfo.Lines.Add('['+E.Classname+'] '+E.Message);
      raise EXDataHttpUnauthorized.Create('Internal Error: CS');
    end;
  end;
  if Query1.RecordCount = 0 then
  begin
    DBSupport.DisconnectQuery(DBConn, Query1);
    raise EXDataHttpUnauthorized.Create('Login not authenticated: Invalid Username.')
  end
  else if Query1.RecordCount > 1 then
  begin
    DBSupport.DisconnectQuery(DBConn, Query1);
    EXDataHttpUnauthorized.Create('Login not authenticated: Ambiguous Login.');
  end;

  // Got the Person ID
  PersonID := Query1.FieldByName('person_id').AsInteger;

  // Ok, we've got a person, let's see if they've got the required Login role
  try
    {$Include sql\system\person_role_check\person_role_check.inc}
    Query1.ParamByName('PERSONID').AsInteger := PersonID;
    Query1.Open;
  except on E: Exception do
    begin
      DBSupport.DisconnectQuery(DBConn, Query1);
      MainForm.mmInfo.Lines.Add('['+E.Classname+'] '+E.Message);
      raise EXDataHttpUnauthorized.Create('Internal Error: PRC');
    end;
  end;
  if Query1.FieldByName('role_id').AsInteger <> 0 then
  begin
    DBSupport.DisconnectQuery(DBConn, Query1);
    raise EXDataHttpUnauthorized.Create('Login not authorized for this Username.');
  end;
  MainForm.mmInfo.lines.add('G');
  // Login role is present, so let's make a note of the other roles
  Roles := '';
  while not(Query1.EOF) do
  begin
    Roles := Roles + Query1.FieldByName('role_id').AsString;

    // Invalid Date Conversin???
//    DStr := Query1.FieldByName('valid_until').AsString;
//    DDate := EncodeDateTime(
//      StrToInt(Copy(DStr,1,4)),
//      StrToInt(Copy(DStr,6,2)),
//      StrToInt(Copy(DStr,9,2)),
//      StrToInt(Copy(DStr,12,2)),
//      StrToInt(Copy(DStr,15,2)),
//      StrToInt(Copy(DStr,18,2)),
//      0
//    );
//    if not(Query1.FieldByName('valid_until').isNull) and
//       (ExpiresAt > TTimeZone.Local.ToLocalTIme(DDate))
//    then ExpiresAt := TTimeZone.Local.ToLocalTime(DDate);

    // Limit token validity of role expires before token expires
    if not(Query1.FieldByName('valid_until').isNull) and
       (ExpiresAt > TTimeZone.Local.ToLocalTIme(Query1.FieldByName('valid_until').AsDateTime))
    then ExpiresAt := TTimeZone.Local.ToLocalTime(Query1.FieldByName('valid_until').AsDateTime);

    Query1.Next;
    if not(Query1.EOF) then Roles := Roles + ',';
  end;

  // Get the first available EMail address if possible
  EMailAddress := 'unavailable';
  try
    {$Include sql\system\contact_email\contact_email.inc}
    Query1.ParamByName('PERSONID').AsInteger := PersonID;
    Query1.Open;
    if Query1.RecordCount > 0
    then EMailAddress := Query1.FieldByName('value').AsString;
  except on E: Exception do
    begin
      DBSupport.DisconnectQuery(DBConn, Query1);
      MainForm.mmInfo.Lines.Add('['+E.Classname+'] '+E.Message);
      raise EXDataHttpUnauthorized.Create('Internal Error: CE');
    end;
  end;

  // Finally, let's check the actual passowrd.
  PasswordHash := DBSupport.HashThis('XData-Password:'+Trim(Password));
  try
    {$Include sql\system\person_password_check\person_password_check.inc}
    Query1.ParamByName('PERSONID').AsInteger := PersonID;
    Query1.ParamByName('PASSWORDHASH').AsString := PasswordHash;
    Query1.Open;
  except on E: Exception do
    begin
      DBSupport.DisconnectQuery(DBConn, Query1);
      MainForm.mmInfo.Lines.Add('['+E.Classname+'] '+E.Message);
      raise EXDataHttpUnauthorized.Create('Internal Error: PPC');
    end;
  end;
  if Query1.RecordCount <> 1 then
  begin
    DBSupport.DisconnectQuery(DBConn, Query1);
    raise EXDataHttpUnauthorized.Create('Login not authenticated: Invalid Password');
  end;

  // Login has been authenticated and authorized.

  // Generate a new JWT
  JWT := TJWT.Create;
  try
    // Setup some Claims
    JWT.Claims.Issuer := MainForm.AppName;
    JWT.Claims.SetClaimOfType<string>( 'ver', MainForm.AppVersion );
    JWT.Claims.SetClaimOfType<string>( 'tzn', TZ );
    JWT.Claims.SetClaimOfType<integer>('usr', PersonID );
    JWT.Claims.SetClaimOfType<string>( 'app', ApplicationName );
    JWT.Claims.SetClaimOfType<string>( 'dbn', DatabaseName );
    JWT.Claims.SetClaimOfType<string>( 'dbe', DatabaseEngine );
    JWT.Claims.SetClaimOfType<string>( 'rol', Roles );
    JWT.Claims.SetClaimOfType<string>( 'eml', EMailAddress );
    JWT.Claims.SetClaimOfType<string>( 'fnm', Query1.FieldByName('first_name').AsString );
    JWT.Claims.SetClaimOfType<string>( 'mnm', Query1.FieldByName('middle_name').AsString );
    JWT.Claims.SetClaimOfType<string>( 'lnm', Query1.FieldByName('last_name').AsString );
    JWT.Claims.SetClaimOfType<string>( 'anm', Query1.FieldByName('account_name').AsString );
    JWT.Claims.SetClaimOfType<string>( 'net', TXDataOperationContext.Current.Request.RemoteIP );
    JWT.Claims.SetClaimOfType<string>( 'aft', FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz',  TTimeZone.local.ToUniversalTime(IssuedAt))+' UTC');
    JWT.Claims.SetClaimOfType<string>( 'unt', FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz',  TTimeZone.local.ToUniversalTime(ExpiresAt))+' UTC');
//    JWT.Claims.SetClaimOfType<int64>('iat', MillisecondsBetween(TTimeZone.local.ToUniversalTime(IssuedAt), EncodeDateTime(1970,1,1,0,0,0,0)));
//    JWT.Claims.SetClaimOfType<int64>('exp', MillisecondsBetween(TTimeZone.local.ToUniversalTime(ExpiresAt), EncodeDateTime(1970,1,1,0,0,0,0)));
    JWT.Claims.SetClaimOfType<integer>('iat', DateTimeToUnix(TTimeZone.local.ToUniversalTime(IssuedAt)));
    JWT.Claims.Expiration := ExpiresAt; // Gets converted to UTC automatically

    // Generate the actual JWT
    JWTSTring := 'Bearer '+TJOSE.SHA256CompactToken(ServerContainer.XDataServerJWT.Secret, JWT);
    Result := TStringStream.Create(JWTString);

  finally
    JWT.Free;
  end;

  // Add the JWT to a table that we'll use to help with expring tokens
  try
    {$Include sql\system\token_insert\token_insert.inc}
    Query1.ParamByName('TOKENHASH').AsString := DBSupport.HashThis(JWTString);
    Query1.ParamByName('PERSONID').AsInteger := PersonID;
    Query1.ParamByName('VALIDAFTER').AsDateTime := TTimeZone.local.ToUniversalTime(IssuedAt);
    Query1.ParamByName('VALIDUNTIL').AsDateTime := TTimeZone.local.ToUniversalTime(ExpiresAt);
    Query1.ParamByName('APPLICATION').AsString := ApplicationName;
    Query1.ParamByName('VERSION').AsString := MainForm.AppVersion;
    Query1.ParamByName('IPADDRESS').AsString := TXDataOperationContext.Current.Request.RemoteIP;
    Query1.ExecSQL;
  except on E: Exception do
    begin
      DBSupport.DisconnectQuery(DBConn, Query1);
      MainForm.mmInfo.Lines.Add('['+E.Classname+'] '+E.Message);
      raise EXDataHttpUnauthorized.Create('Internal Error: TI');
    end;
  end;

  // Keep track of login history
  try
    {$Include sql\system\login_history_insert\login_history_insert.inc}
    Query1.ParamByName('LOGGEDIN').AsDateTime := TTimeZone.local.ToUniversalTime(IssuedAt);
    Query1.ParamByName('IPADDRESS').AsString := TXDataOperationContext.Current.Request.RemoteIP;
    Query1.ParamByName('PERSONID').AsInteger := PersonID;
    Query1.ParamByName('APPLICATION').AsString := ApplicationName;
    Query1.ParamByName('VERSION').AsString := MainForm.AppVersion;
    Query1.ExecSQL;
  except on E: Exception do
    begin
      DBSupport.DisconnectQuery(DBConn, Query1);
      MainForm.mmInfo.Lines.Add('['+E.Classname+'] '+E.Message);
      raise EXDataHttpUnauthorized.Create('Internal Error: LHI');
    end;
  end;

  // Cleanup after login
  try
    {$Include sql\system\login_cleanup\login_cleanup.inc}
    Query1.ParamByName('IPADDRESS').AsString := TXDataOperationContext.Current.Request.RemoteIP;
    Query1.ParamByName('LOGINID').AsString := LowerCase(Login_ID);
    Query1.ExecSQL;
  except on E: Exception do
    begin
      DBSupport.DisconnectQuery(DBConn, Query1);
      MainForm.mmInfo.Lines.Add('['+E.Classname+'] '+E.Message);
      raise EXDataHttpUnauthorized.Create('Internal Error: LCI');
    end;
  end;

  // Keep track of endpoint history
  try
    {$Include sql\system\endpoint_history_insert\endpoint_history_insert.inc}
    Query1.ParamByName('PERSONID').AsInteger := PersonID;
    Query1.ParamByName('ENDPOINT').AsString := 'SystemService.Login';
    Query1.ParamByName('ACCESSED').AsDateTime := TTimeZone.local.ToUniversalTime(ElapsedTime);
    Query1.ParamByName('IPADDRESS').AsString := TXDataOperationContext.Current.Request.RemoteIP;
    Query1.ParamByName('APPLICATION').AsString := ApplicationName;
    Query1.ParamByName('VERSION').AsString := MainForm.AppVersion;
    Query1.ParamByName('DATABASENAME').AsString := DatabaseName;
    Query1.ParamByName('DATABASEENGINE').AsString := DatabaseEngine;
    Query1.ParamByName('EXECUTIONMS').AsInteger := MillisecondsBetween(Now,ElapsedTime);
    Query1.ParamByName('DETAILS').AsString := '['+Login_ID+'] [Passowrd] [API_Key] ['+TZ+']';
    Query1.ExecSQL;
  except on E: Exception do
    begin
      DBSupport.DisconnectQuery(DBConn, Query1);
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

function TSystemService.Logout(ActionSession: String; ActionLog: String): TStream;
var
  DBConn: TFDConnection;
  Query1: TFDQuery;
  DatabaseEngine: String;
  DatabaseName: String;
  ElapsedTime: TDateTime;

  OldJWT: String;

  User: IUserIdentity;
begin
  // Returning JWT, so flag it as such
  TXDataOperationContext.Current.Response.Headers.SetValue('content-type', 'application/json');

  // Time this event
  ElapsedTime := Now;

  // Get data from the JWT
  User := TXDataOperationContext.Current.Request.User;
  OldJWT := TXDataOperationContext.Current.Request.Headers.Get('Authorization');
  if (User = nil) then raise EXDataHttpUnauthorized.Create('Missing authentication');

  // Setup DB connection and query
  DatabaseName := MainForm.DatabaseName;
  DatabaseEngine := MainForm.DatabaseEngine;
  try
    DBSupport.ConnectQuery(DBConn, Query1, DatabaseName, DatabaseEngine);
  except on E: Exception do
    begin
      DBSupport.DisconnectQuery(DBConn, Query1);
      MainForm.mmInfo.Lines.Add('['+E.Classname+'] '+E.Message);
      raise EXDataHttpUnauthorized.Create('Internal Error: CQ');
    end;
  end;

  // Check if we've got a valid JWT (one that has not been revoked)
  try
    {$Include sql\system\token_check\token_check.inc}
    Query1.ParamByName('TOKENHASH').AsString := DBSupport.HashThis(OldJWT);
    Query1.ParamByName('IPADDRESS').AsString := TXDataOperationContext.Current.Request.RemoteIP;
    Query1.Open;
  except on E: Exception do
    begin
      MainForm.mmInfo.Lines.Add('['+E.Classname+'] '+E.Message);
      raise EXDataHttpUnauthorized.Create('Internal Error: JC');
    end;
  end;
  if Query1.RecordCount <> 1 then
  begin
    DBSupport.DisconnectQuery(DBConn, Query1);
    raise EXDataHttpUnauthorized.Create('JWT was not validated');
  end;

  // Revoke JWT
  try
    {$Include sql\system\token_revoke\token_revoke.inc}
    Query1.ParamByName('TOKENHASH').AsString := DBSupport.HashThis(OldJWT);
    Query1.ExecSQL;
  except on E: Exception do
    begin
      MainForm.mmInfo.Lines.Add('['+E.Classname+'] '+E.Message);
      raise EXDataHttpUnauthorized.Create('Internal Error: TR');
    end;
  end;

  // Record Action History
  try
    {$Include sql\system\action_history_insert\action_history_insert.inc}
    Query1.ParamByName('PERSONID').AsInteger := User.Claims.Find('usr').asInteger;
    Query1.ParamByName('IPADDRESS').AsString := TXDataOperationContext.Current.Request.RemoteIP;
    Query1.ParamByName('APPLICATION').AsString := User.Claims.Find('app').asString;
    Query1.ParamByName('VERSION').AsString := User.Claims.Find('ver').asString;
    Query1.ParamByName('SESSIONID').AsString := ActionSession;
    Query1.ParamByName('SESSIONSTART').AsDateTime := DBSupport.DecodeSession(ActionSession);
    Query1.ParamByName('SESSIONRECORDED').AsDateTime := TTimeZone.local.ToUniversalTime(Now);
    Query1.ParamByName('ACTIONS').AsString := ActionLog;
    Query1.ExecSQL;
  except on E: Exception do
    begin
      DBSupport.DisconnectQuery(DBConn, Query1);
      MainForm.mmInfo.Lines.Add('['+E.Classname+'] '+E.Message);
      raise EXDataHttpUnauthorized.Create('Internal Error: EHI');
    end;
  end;

  // Keep track of endpoint history
  try
    {$Include sql\system\endpoint_history_insert\endpoint_history_insert.inc}
    Query1.ParamByName('PERSONID').AsInteger := User.Claims.Find('usr').asInteger;
    Query1.ParamByName('ENDPOINT').AsString := 'SystemService.Renew';
    Query1.ParamByName('ACCESSED').AsDateTime := TTimeZone.local.ToUniversalTime(ElapsedTime);
    Query1.ParamByName('IPADDRESS').AsString := TXDataOperationContext.Current.Request.RemoteIP;
    Query1.ParamByName('APPLICATION').AsString := User.Claims.Find('app').asString;
    Query1.ParamByName('VERSION').AsString := User.Claims.Find('ver').asString;
    Query1.ParamByName('DATABASENAME').AsString := User.Claims.Find('dbn').asString;
    Query1.ParamByName('DATABASEENGINE').AsString := User.Claims.Find('dbe').asString;
    Query1.ParamByName('EXECUTIONMS').AsInteger := MillisecondsBetween(Now,ElapsedTime);
    Query1.ParamByName('DETAILS').AsString := '['+User.Claims.Find('anm').asString+']';
    Query1.ExecSQL;
  except on E: Exception do
    begin
      DBSupport.DisconnectQuery(DBConn, Query1);
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

  Result := TStringStream.Create('{"Message":"Logout Complete"}');
end;

function TSystemService.Renew(ActionSession: String; ActionLog: String): TStream;
var
  DBConn: TFDConnection;
  Query1: TFDQuery;
  DatabaseEngine: String;
  DatabaseName: String;
  ElapsedTime: TDateTime;

  OldJWT: String;
  JWT: TJWT;
  JWTString: String;
  IssuedAt: TDateTime;
  ExpiresAt: TDateTime;
  Roles: String;

  User: IUserIdentity;
begin
  // Returning JWT, so flag it as such
  TXDataOperationContext.Current.Response.Headers.SetValue('content-type', 'application/jwt');

  // Time this event
  ElapsedTime := Now;

  // We're creating a JWT now that is valid for JWT_PERIOD minutes
  IssuedAt := Now;
  ExpiresAt := IncMinute(IssuedAt, JWT_PERIOD);

  // Get data from the JWT
  User := TXDataOperationContext.Current.Request.User;
  OldJWT := TXDataOperationContext.Current.Request.Headers.Get('Authorization');
  if (User = nil) then raise EXDataHttpUnauthorized.Create('Missing authentication');

  // Setup DB connection and query
  DatabaseName := MainForm.DatabaseName;
  DatabaseEngine := MainForm.DatabaseEngine;
  try
    DBSupport.ConnectQuery(DBConn, Query1, DatabaseName, DatabaseEngine);
  except on E: Exception do
    begin
      DBSupport.DisconnectQuery(DBConn, Query1);
      MainForm.mmInfo.Lines.Add('['+E.Classname+'] '+E.Message);
      raise EXDataHttpUnauthorized.Create('Internal Error: CQ');
    end;
  end;

  // Check if we've got a valid JWT (one that has not been revoked)
  try
    {$Include sql\system\token_check\token_check.inc}
    Query1.ParamByName('TOKENHASH').AsString := DBSupport.HashThis(OldJWT);
    Query1.ParamByName('IPADDRESS').AsString := TXDataOperationContext.Current.Request.RemoteIP;
    Query1.Open;
  except on E: Exception do
    begin
      MainForm.mmInfo.Lines.Add('['+E.Classname+'] '+E.Message);
      raise EXDataHttpUnauthorized.Create('Internal Error: JC');
    end;
  end;
  if Query1.RecordCount <> 1 then
  begin
    DBSupport.DisconnectQuery(DBConn, Query1);
    raise EXDataHttpUnauthorized.Create('JWT was not validated');
  end;

  // Let's see if they've (still) got the required Login role
  try
    {$Include sql\system\person_role_check\person_role_check.inc}
    Query1.ParamByName('PERSONID').AsInteger := User.Claims.Find('usr').asInteger;
    Query1.Open;
  except on E: Exception do
    begin
      DBSupport.DisconnectQuery(DBConn, Query1);
      MainForm.mmInfo.Lines.Add('['+E.Classname+'] '+E.Message);
      raise EXDataHttpUnauthorized.Create('Internal Error: PRC');
    end;
  end;
  if Query1.FieldByName('role_id').AsInteger <> 0 then
  begin
    DBSupport.DisconnectQuery(DBConn, Query1);
    raise EXDataHttpUnauthorized.Create('Login not authorized');
  end;

  // Login role is present, so let's make a note of the other roles
  Roles := '';
  while not(Query1.EOF) do
  begin
    Roles := Roles + Query1.FieldByName('role_id').AsString;

    // Limit token validity of role expires before token expires
    if not(Query1.FieldByName('valid_until').isNull) and
       (ExpiresAt > TTimeZone.Local.ToLocalTIme(Query1.FieldByName('valid_until').AsDateTime))
    then ExpiresAt := TTimeZone.Local.ToLocalTime(Query1.FieldByName('valid_until').AsDateTime);

    Query1.Next;
    if not(Query1.EOF) then Roles := Roles + ',';
  end;

  // Check if we've got a valid JWT (one that has not been revoked)
  try
    {$Include sql\system\token_check\token_check.inc}
    Query1.ParamByName('TOKENHASH').AsString := DBSupport.HashThis(OldJWT);
    Query1.ParamByName('IPADDRESS').AsString := TXDataOperationContext.Current.Request.RemoteIP;
    Query1.Open;
  except on E: Exception do
    begin
      MainForm.mmInfo.Lines.Add('['+E.Classname+'] '+E.Message);
      raise EXDataHttpUnauthorized.Create('Internal Error: JC');
    end;
  end;
  if Query1.RecordCount <> 1 then
  begin
    DBSupport.DisconnectQuery(DBConn, Query1);
    raise EXDataHttpUnauthorized.Create('JWT was not validated');
  end;

  // Revoke JWT
//  try
//    {$Include sql\system\token_revoke\token_revoke.inc}
//    Query1.ParamByName('TOKENHASH').AsString := DBSupport.HashThis(OldJWT);
//    Query1.ExecSQL;
//  except on E: Exception do
//    begin
//      MainForm.mmInfo.Lines.Add('['+E.Classname+'] '+E.Message);
//      raise EXDataHttpUnauthorized.Create('Internal Error: TR');
//    end;
//  end;

  // Generate a new JWT
  JWT := TJWT.Create;
  try
    // Setup some Claims
    JWT.Claims.Issuer := MainForm.AppName;
    JWT.Claims.SetClaimOfType<string>( 'ver', User.Claims.Find('ver').asString );
    JWT.Claims.SetClaimOfType<string>( 'tzn', User.Claims.Find('tzn').asString );
    JWT.Claims.SetClaimOfType<integer>('usr', User.Claims.Find('usr').asInteger);
    JWT.Claims.SetClaimOfType<string>( 'app', User.Claims.Find('app').asString );
    JWT.Claims.SetClaimOfType<string>( 'dbn', User.Claims.Find('dbn').asString );
    JWT.Claims.SetClaimOfType<string>( 'dbe', User.Claims.Find('dbe').asString );
    JWT.Claims.SetClaimOfType<string>( 'rol', Roles );
    JWT.Claims.SetClaimOfType<string>( 'eml', User.Claims.Find('eml').asString );
    JWT.Claims.SetClaimOfType<string>( 'fnm', User.Claims.Find('fnm').asString );
    JWT.Claims.SetClaimOfType<string>( 'mnm', User.Claims.Find('mnm').asString );
    JWT.Claims.SetClaimOfType<string>( 'lnm', User.Claims.Find('lnm').asString );
    JWT.Claims.SetClaimOfType<string>( 'anm', User.Claims.Find('anm').asString );
    JWT.Claims.SetClaimOfType<string>( 'net', User.Claims.Find('net').asString );
    JWT.Claims.SetClaimOfType<string>( 'aft', FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz',  TTimeZone.local.ToUniversalTime(IssuedAt))+' UTC');
    JWT.Claims.SetClaimOfType<string>( 'unt', FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz',  TTimeZone.local.ToUniversalTime(ExpiresAt))+' UTC');
    JWT.Claims.SetClaimOfType<integer>('iat', DateTimeToUnix(TTimeZone.local.ToUniversalTime(IssuedAt)));
    JWT.Claims.Expiration := ExpiresAt; // Gets converted to UTC automatically

    // Generate the actual JWT
    JWTSTring := 'Bearer '+TJOSE.SHA256CompactToken(ServerContainer.XDataServerJWT.Secret, JWT);
    Result := TStringStream.Create(JWTString);

  finally
    JWT.Free;
  end;

  // Add the JWT to a table that we'll use to help with expring tokens
  try
    {$Include sql\system\token_insert\token_insert.inc}
    Query1.ParamByName('TOKENHASH').AsString := DBSupport.HashThis(JWTString);
    Query1.ParamByName('PERSONID').AsInteger := User.Claims.Find('usr').asInteger;
    Query1.ParamByName('VALIDAFTER').AsDateTime := TTimeZone.local.ToUniversalTime(IssuedAt);
    Query1.ParamByName('VALIDUNTIL').AsDateTime := TTimeZone.local.ToUniversalTime(ExpiresAt);
    Query1.ParamByName('APPLICATION').AsString := User.Claims.Find('app').asString;
    Query1.ParamByName('VERSION').AsString := User.Claims.Find('ver').asString;
    Query1.ParamByName('IPADDRESS').AsString := TXDataOperationContext.Current.Request.RemoteIP;
    Query1.ExecSQL;
  except on E: Exception do
    begin
      DBSupport.DisconnectQuery(DBConn, Query1);
      MainForm.mmInfo.Lines.Add('['+E.Classname+'] '+E.Message);
      raise EXDataHttpUnauthorized.Create('Internal Error: TI');
    end;
  end;

  // Record Action History
  try
    {$Include sql\system\action_history_insert\action_history_insert.inc}
    Query1.ParamByName('PERSONID').AsInteger := User.Claims.Find('usr').asInteger;
    Query1.ParamByName('IPADDRESS').AsString := TXDataOperationContext.Current.Request.RemoteIP;
    Query1.ParamByName('APPLICATION').AsString := User.Claims.Find('app').asString;
    Query1.ParamByName('VERSION').AsString := User.Claims.Find('ver').asString;
    Query1.ParamByName('SESSIONID').AsString := ActionSession;
    Query1.ParamByName('SESSIONSTART').AsDateTime := DBSupport.DecodeSession(ActionSession);
    Query1.ParamByName('SESSIONRECORDED').AsDateTime := TTimeZone.local.ToUniversalTime(Now);
    Query1.ParamByName('ACTIONS').AsString := ActionLog;
    Query1.ExecSQL;
  except on E: Exception do
    begin
      DBSupport.DisconnectQuery(DBConn, Query1);
      MainForm.mmInfo.Lines.Add('['+E.Classname+'] '+E.Message);
      raise EXDataHttpUnauthorized.Create('Internal Error: AH');
    end;
  end;

  // Keep track of endpoint history
  try
    {$Include sql\system\endpoint_history_insert\endpoint_history_insert.inc}
    Query1.ParamByName('PERSONID').AsInteger := User.Claims.Find('usr').asInteger;
    Query1.ParamByName('ENDPOINT').AsString := 'SystemService.Renew';
    Query1.ParamByName('ACCESSED').AsDateTime := TTimeZone.local.ToUniversalTime(ElapsedTime);
    Query1.ParamByName('IPADDRESS').AsString := TXDataOperationContext.Current.Request.RemoteIP;
    Query1.ParamByName('APPLICATION').AsString := User.Claims.Find('app').asString;
    Query1.ParamByName('VERSION').AsString := User.Claims.Find('ver').asString;
    Query1.ParamByName('DATABASENAME').AsString := User.Claims.Find('dbn').asString;
    Query1.ParamByName('DATABASEENGINE').AsString := User.Claims.Find('dbe').asString;
    Query1.ParamByName('EXECUTIONMS').AsInteger := MillisecondsBetween(Now,ElapsedTime);
    Query1.ParamByName('DETAILS').AsString := '['+User.Claims.Find('anm').asString+']';
    Query1.ExecSQL;
  except on E: Exception do
    begin
      DBSupport.DisconnectQuery(DBConn, Query1);
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

function TSystemService.SearchFontAwesome(Query: String): TStream;
var
  Client: TNetHTTPClient;
  QStream: TStringStream;
  Response: String;
begin
  QStream := TSTringStream.Create(Query);
  Client := TNetHTTPClient.Create(nil);
  Client.Asynchronous := False;
  Client.ContentType := 'application/json';
  Client.SecureProtocols := [THTTPSecureProtocol.SSL3, THTTPSecureProtocol.TLS12];
  Response := Client.Post('https://api.fontawesome.com',QStream).ContentAsString;
  Result := TStringStream.Create(Response);
  Client.Free;
  QStream.Free;
end;

function TSystemService.SearchIconSets(SearchTerms, SearchSets: String; Results: Integer): TStream;
var
  IconsFound: TJSONArray;
  IconSet: TJSONObject;
  IconSetList: TStringList;
  i: integer;
  j: integer;
  k: integer;
  IconName: String;
  Icon: TJSONArray;
  IconCount: Integer;
  Terms:TStringList;
  Matched: Boolean;
begin
  // Returning JSON, so flag it as such
  TXDataOperationContext.Current.Response.Headers.SetValue('content-type', 'application/json');

  // JSON Array we'll be returning
  IconsFound := TJSONArray.Create;
  IconCount := 0;

  // If all, will just iterate through the sets
  // Otherwise, we'll build a list and only iterate through the contents of that list
  IconSetList := TStringList.Create;
  if SearchSets = 'all' then
  begin
    k := Mainform.AppIcons.Count;
  end
  else
  begin
    IconSetList.CommaText := SearchSets;
    k := IconSetList.Count;
  end;

  // Sort out Search Terms
  Terms := TStringList.Create;
  Terms.CommaText := StringReplace(Trim(SearchTerms),' ',',',[rfReplaceAll]);

  i := 0;
  while (i < k) and (IconCount < Results) and (Terms.Count > 0) do
  begin

    // Load up an Icon Set to Search
    if SearchSets = 'all'
    then IconSet := (MainForm.AppIcons.Items[i] as TJSONObject).GetValue('icons') as TJSONObject
    else IconSet := (MainForm.AppIcons.Items[StrToInt(IconSetList[i])] as TJSONObject).GetValue('icons') as TJSONObject;

    // Search all the icons in the Set
    for j := 0 to IconSet.Count-1 do
    begin

      if (IconCount < Results) then
      begin

        IconName := (Iconset.Pairs[j].JSONString as TJSONString).Value;

        // See if there is a match using the number of terms we have
        if Terms.Count = 1
        then Matched := (Pos(Terms[0], IconName) > 0)
        else if Terms.Count = 2
             then Matched := (Pos(Terms[0], IconName) > 0) and (Pos(Terms[1], IconName) > 0)
             else Matched := (Pos(Terms[0], IconName) > 0) and (Pos(Terms[1], IconName) > 0) and (Pos(Terms[2], IconName) > 0);

        // Got a match
        if Matched then
        begin
          Icon := TJSONArray.Create;
          Icon.Add(IconName);

          // Need to know what set it is in so we get lookup default width, height, license, set name
          if SearchSets = 'all'
          then Icon.Add(i)
          else Icon.Add(IconSetList[i]);

          // Add in the icon data - the SVG and width/height overrides
          Icon.Add(IconSet.GetValue(IconName) as TJSONObject);

          // Save to our set that we're returning
          IconsFound.Add(Icon);
          IconCount := IconCount + 1;
        end;
      end;
    end;

    i := i + 1;
  end;

  // Return the array of results
  Result := TStringStream.Create(IconsFound.ToString);
end;

initialization
  RegisterServiceType(TSystemService);

end.
