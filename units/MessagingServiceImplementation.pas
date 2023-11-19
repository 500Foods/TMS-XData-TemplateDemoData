unit MessagingServiceImplementation;

interface

uses
  System.Classes,
  System.SysUtils,
  System.JSON,
  System.DateUtils,
  System.Generics.Collections,

  System.NetEncoding,
  System.Net.URLClient,
  System.Net.HttpClientComponent,
  System.Net.HttpClient,
  System.Net.Mime,

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

  IdHMACSHA1,
  IdCoderMIME,
  IdGlobal,

  MessagingService;

type
  [ServiceImplementation]
  TMessagingService = class(TInterfacedObject, IMessagingService)
  private
    function Callback(Incoming: TStream):TStream;
    function Fallback(Incoming: TStream):TStream;
    function SendAMessage(MessageService: String; Destination: String; AMessage: String):TStream;
  end;

implementation

uses Unit2, Unit3;

function TMessagingService.Callback(Incoming: TStream):TStream;
var
  i: Integer;
  Request: TStringList;
  Processed: TStringList;
  Response: TStringList;

  Signature: String;
  SignatureGEN: String;
  SignatureURL: String;
  SignaturePAR: String;
  SignatureTOK: String;

  DBConn: TFDConnection;
  Query1: TFDQuery;
  DatabaseName: String;
  DatabaseEngine: String;
  ElapsedTime: TDateTime;

  ServiceName: String;
  AccountNumber: String;
  AuthToken: String;
  CallbackURL: String;
  FieldName: String;
  FieldValue: String;
  AddOns: TJSONObject;

  function GenerateSignature(aURL, aParameterList, aKey: String):String;
  begin
     with TIdHMACSHA1.Create do
     try
       Key := ToBytes(aKey);
       Result := TIdEncoderMIME.EncodeBytes(HashValue(ToBytes(aURL+aParameterList)));
     finally
       Free;
     end;
  end;

begin
  ElapsedTime := Now;
  
  // Get Messaging System Configuration
  ServiceName := '';
  AccountNumber := '';
  AuthToken := '';
  CallbackURL := '';
  if (MainForm.AppConfiguration.GetValue('Messaging Services') <> nil) then
  begin
    if ((MainForm.AppConfiguration.GetValue('Messaging Services') as TJSONObject).GetValue('Twilio') <> nil) then
    begin
      if (((MainForm.AppConfiguration.GetValue('Messaging Services') as TJSONObject).GetValue('Twilio') as TJSONObject).GetValue('Service Name') <> nil) 
      then ServiceName := (((MainForm.AppConfiguration.GetValue('Messaging Services') as TJSONObject).GetValue('Twilio') as TJSONObject).GetValue('Service Name') as TJSONString).Value
      else raise EXDataHttpUnauthorized.Create('Invalid Messaging System Configuration: Service Name');
      
      if (((MainForm.AppConfiguration.GetValue('Messaging Services') as TJSONObject).GetValue('Twilio') as TJSONObject).GetValue('Auth Token') <> nil) 
      then AuthToken := (((MainForm.AppConfiguration.GetValue('Messaging Services') as TJSONObject).GetValue('Twilio') as TJSONObject).GetValue('Auth Token') as TJSONString).Value
      else raise EXDataHttpUnauthorized.Create('Invalid Messaging System Configuration: Auth Token');

      if (((MainForm.AppConfiguration.GetValue('Messaging Services') as TJSONObject).GetValue('Twilio') as TJSONObject).GetValue('Account') <> nil) 
      then AccountNumber := (((MainForm.AppConfiguration.GetValue('Messaging Services') as TJSONObject).GetValue('Twilio') as TJSONObject).GetValue('Account') as TJSONString).Value
      else raise EXDataHttpUnauthorized.Create('Invalid Messaging System Configuration: Account');

      if (((MainForm.AppConfiguration.GetValue('Messaging Services') as TJSONObject).GetValue('Twilio') as TJSONObject).GetValue('Callback URL') <> nil) 
      then CallbackURL := (((MainForm.AppConfiguration.GetValue('Messaging Services') as TJSONObject).GetValue('Twilio') as TJSONObject).GetValue('Callback URL') as TJSONString).Value
      else raise EXDataHttpUnauthorized.Create('Invalid Messaging System Configuration: Callback URL');
    end;
  end;
  if (ServiceName = '') or (AccountNumber = '') or (AuthToken = '') or (CallbackURL = '') 
  then raise EXDataHttpUnauthorized.Create('Invalid Messaging System Configuration');

  Request := TStringList.Create;
  Request.LoadFromStream(Incoming);

  Processed := TStringList.Create;
  Processed.Delimiter := '&';
  Processed.DelimitedText := Request.Text;
  Processed.Sort;

//  MainForm.LogEvent('Parameters');
//  MainForm.LogEvent(Processed.Text);

  i := 0;
  SignaturePAR := '';
  while i < Processed.Count do
  begin
    SignaturePAR := SignaturePAR + TNetEncoding.URL.Decode(StringReplace(Processed[i],'=','',[]));
    i := i + 1;
  end;

//  MainForm.LogEvent('Signature Parameters');
//  MainForm.LogEvent(SignaturePAR);

  Signature := TXdataOperationContext.Current.Request.Headers.Get('x-twilio-signature');
  SignatureURL := CallbackURL;
  SignatureTOK := AuthToken;
  SignatureGEN := GenerateSignature(SignatureURL, SignaturePAR, SignatureTOK);

//  MainForm.LogEvent('Signature');
//  MainForm.LogEvent(Signature);
//  MainForm.LogEvent('Signature Generated');
//  MainForm.LogEvent(SignatureGEN);

  // Not authenticated
  if (SignatureGEN <> Signature) then
  begin
//    MainForm.LogEvent('Signature NOT Matched');
    Request.Free;
    Processed.Free;
    raise EXDataHttpUnauthorized.Create('Invalid Signature Detected');
  end;
//  MainForm.LogEvent('Signature Matched');

  // Setup DB connection and query
  // NOTE: Image access is anonymous, but database access is usually not,
  // so we should be careful how and when this is called
  try
    DatabaseName := MainForm.DatabaseName;
    DatabaseEngine := MainForm.DatabaseEngine;
    DBSupport.ConnectQuery(DBConn, Query1, DatabaseName, DatabaseEngine);
  except on E: Exception do
    begin
      MainForm.mmInfo.Lines.Add('['+E.Classname+'] '+E.Message);
      raise EXDataHttpUnauthorized.Create('Internal Error: M-C-CQ');
    end;
  end;

  // Use this query to log messages. Set parameters to null string to start
  {$Include sql\messaging\messaging\log_message.inc}
  Query1.ParamByName('service').AsString := ServiceName;
  for i := 1 to Query1.ParamCount - 1 do
    Query1.Params[i].AsString := '';

  i := 0;
  while i < Processed.Count do
  begin
    FieldName := '';
    FieldValue := '';
    if Pos('=', Processed[i]) > 0 then
    begin
      FieldName := Copy(Processed[i], 1, Pos('=', Processed[i]) - 1);
      FieldValue := TNetEncoding.URL.Decode(Copy(Processed[i], Pos('=', Processed[i]) + 1, Length(Processed[i])));
    end;

    // Filter out any junk, like when uploading a file via Swagger
    if FieldName <> '' then
    begin
      // Parse JSON of AddOns
      if FieldName = 'AddOns' then
      begin
//        MainForm.LogEvent('- '+FieldName+'='+FieldValue);
        AddOns := TJSONObject.ParseJSONValue(FieldValue) as TJSONObject;
        Query1.ParamByName('AddOns').AsString := Addons.toString;
      end

      // To= is assigned to ToNum field
      else if FieldName = 'To' then
      begin
//        MainForm.LogEvent('- '+FieldName+'='+FieldValue);
        Query1.ParamByName('ToNum').AsString := FieldValue;
      end

      // From= is assigned to FromNum field
      else if FieldName = 'From' then
      begin
//        MainForm.LogEvent('- '+FieldName+'='+FieldValue);
        Query1.ParamByName('FromNum').AsString := FieldValue;
      end

      // Process Other Fields
      else
      begin
//        MainForm.LogEvent('- '+FieldName+'='+FieldValue);
        if Query1.Params.FindParam(FieldName) <> nil then
        begin
          Query1.ParamByName(FieldName).AsString := FieldValue;
        end
        else
        begin
          MainForm.LogEvent('WARNING: Message Received with Unexpected Field: ');
          MainForm.LogEvent('[ '+Processed[i]+ ' ]');
        end;
      end;

    end;
    i := i + 1;
  end;

  // Log the callback request
  try
    Query1.ExecSQL;
  except on E: Exception do
    begin
      MainForm.LogException('MessagingService.Callback: Log Query', E.ClassName, E.Message, Query1.SQL.Text);
    end;
  end;

  // Returning XML, so flag it as such
  TXDataOperationContext.Current.Response.Headers.SetValue('content-type', 'text/xml');

  // Return an empty, but valid, response
  Result := TMemoryStream.Create;
  Response := TStringList.Create;
  Response.Add('<Response></Response>');
  Response.SaveToStream(Result);

  //Cleanup
  Request.Free;
  Processed.Free;
  Response.Free;

  // Keep track of endpoint history
  try
    {$Include sql\system\endpoint_history_insert\endpoint_history_insert.inc}
    Query1.ParamByName('PERSONID').AsInteger := 1;
    Query1.ParamByName('ENDPOINT').AsString := 'MessagingService.Callback';
    Query1.ParamByName('ACCESSED').AsDateTime := TTimeZone.local.ToUniversalTime(ElapsedTime);
    Query1.ParamByName('IPADDRESS').AsString := TXDataOperationContext.Current.Request.RemoteIP;
    Query1.ParamByName('APPLICATION').AsString := MainForm.AppName;
    Query1.ParamByName('VERSION').AsString := MainForm.AppVersion;
    Query1.ParamByName('DATABASENAME').AsString := DatabaseName;
    Query1.ParamByName('DATABASEENGINE').AsString := DatabaseEngine;
    Query1.ParamByName('EXECUTIONMS').AsInteger := MillisecondsBetween(Now,ElapsedTime);
    Query1.ParamByName('DETAILS').AsString := '['+ServiceName+']';
    Query1.ExecSQL;
  except on E: Exception do
    begin
      MainForm.mmInfo.Lines.Add('['+E.Classname+'] '+E.Message);
      raise EXDataHttpUnauthorized.Create('Internal Error: M-C-EHI');
    end;
  end;

  // All Done
  try
    DBSupport.DisconnectQuery(DBConn, Query1);
  except on E: Exception do
    begin
      MainForm.mmInfo.Lines.Add('['+E.Classname+'] '+E.Message);
      raise EXDataHttpUnauthorized.Create('Internal Error: M-C-DQ');
    end;
  end;

end;

function TMessagingService.Fallback(Incoming: TStream):TStream;
var
  i: Integer;
  Request: TStringList;
  Processed: TStringList;
  Response: TStringList;

  Signature: String;
  SignatureGEN: String;
  SignatureURL: String;
  SignaturePAR: String;
  SignatureTOK: String;

  DBConn: TFDConnection;
  Query1: TFDQuery;
  DatabaseName: String;
  DatabaseEngine: String;
  ElapsedTime: TDateTime;

  ServiceName: String;
  AccountNumber: String;
  AuthToken: String;
  FallbackURL: String;
  FieldName: String;
  FieldValue: String;
  AddOns: TJSONObject;

  function GenerateSignature(aURL, aParameterList, aKey: String):String;
  begin
     with TIdHMACSHA1.Create do
     try
       Key := ToBytes(aKey);
       Result := TIdEncoderMIME.EncodeBytes(HashValue(ToBytes(aURL+aParameterList)));
     finally
       Free;
     end;
  end;

begin
  ElapsedTime := Now;
  
  // Get Messaging System Configuration
  ServiceName := '';
  AccountNumber := '';
  AuthToken := '';
  FallbackURL := '';
  if (MainForm.AppConfiguration.GetValue('Messaging Services') <> nil) then
  begin
    if ((MainForm.AppConfiguration.GetValue('Messaging Services') as TJSONObject).GetValue('Twilio') <> nil) then
    begin
      if (((MainForm.AppConfiguration.GetValue('Messaging Services') as TJSONObject).GetValue('Twilio') as TJSONObject).GetValue('Service Name') <> nil) 
      then ServiceName := (((MainForm.AppConfiguration.GetValue('Messaging Services') as TJSONObject).GetValue('Twilio') as TJSONObject).GetValue('Service Name') as TJSONString).Value
      else raise EXDataHttpUnauthorized.Create('Invalid Messaging System Configuration: Service Name');
      
      if (((MainForm.AppConfiguration.GetValue('Messaging Services') as TJSONObject).GetValue('Twilio') as TJSONObject).GetValue('Auth Token') <> nil) 
      then AuthToken := (((MainForm.AppConfiguration.GetValue('Messaging Services') as TJSONObject).GetValue('Twilio') as TJSONObject).GetValue('Auth Token') as TJSONString).Value
      else raise EXDataHttpUnauthorized.Create('Invalid Messaging System Configuration: Auth Token');

      if (((MainForm.AppConfiguration.GetValue('Messaging Services') as TJSONObject).GetValue('Twilio') as TJSONObject).GetValue('Account') <> nil) 
      then AccountNumber := (((MainForm.AppConfiguration.GetValue('Messaging Services') as TJSONObject).GetValue('Twilio') as TJSONObject).GetValue('Account') as TJSONString).Value
      else raise EXDataHttpUnauthorized.Create('Invalid Messaging System Configuration: Account');

      if (((MainForm.AppConfiguration.GetValue('Messaging Services') as TJSONObject).GetValue('Twilio') as TJSONObject).GetValue('Fallback URL') <> nil) 
      then FallbackURL := (((MainForm.AppConfiguration.GetValue('Messaging Services') as TJSONObject).GetValue('Twilio') as TJSONObject).GetValue('Fallback URL') as TJSONString).Value
      else raise EXDataHttpUnauthorized.Create('Invalid Messaging System Configuration: Fallback URL');
    end;
  end;
  if (ServiceName = '') or (AccountNumber = '') or (AuthToken = '') or (FallbackURL = '') 
  then raise EXDataHttpUnauthorized.Create('Invalid Messaging System Configuration');

  Request := TStringList.Create;
  Request.LoadFromStream(Incoming);

  Processed := TStringList.Create;
  Processed.Delimiter := '&';
  Processed.DelimitedText := Request.Text;
  Processed.Sort;

//  MainForm.LogEvent('Parameters');
//  MainForm.LogEvent(Processed.Text);

  i := 0;
  SignaturePAR := '';
  while i < Processed.Count do
  begin
    SignaturePAR := SignaturePAR + TNetEncoding.URL.Decode(StringReplace(Processed[i],'=','',[]));
    i := i + 1;
  end;

//  MainForm.LogEvent('Signature Parameters');
//  MainForm.LogEvent(SignaturePAR);

  Signature := TXdataOperationContext.Current.Request.Headers.Get('x-twilio-signature');
  SignatureURL := FallbackURL;
  SignatureTOK := AuthToken;
  SignatureGEN := GenerateSignature(SignatureURL, SignaturePAR, SignatureTOK);

//  MainForm.LogEvent('Signature');
//  MainForm.LogEvent(Signature);
//  MainForm.LogEvent('Signature Generated');
//  MainForm.LogEvent(SignatureGEN);

  // Not authenticated
  if (SignatureGEN <> Signature) then
  begin
//    MainForm.LogEvent('Signature NOT Matched');
    Request.Free;
    Processed.Free;
    raise EXDataHttpUnauthorized.Create('Invalid Signature Detected');
  end;
//  MainForm.LogEvent('Signature Matched');

  // Setup DB connection and query
  // NOTE: Image access is anonymous, but database access is usually not,
  // so we should be careful how and when this is called
  try
    DatabaseName := MainForm.DatabaseName;
    DatabaseEngine := MainForm.DatabaseEngine;
    DBSupport.ConnectQuery(DBConn, Query1, DatabaseName, DatabaseEngine);
  except on E: Exception do
    begin
      MainForm.mmInfo.Lines.Add('['+E.Classname+'] '+E.Message);
      raise EXDataHttpUnauthorized.Create('Internal Error: M-C-CQ');
    end;
  end;

  // Use this query to log messages. Set parameters to null string to start
  {$Include sql\messaging\messaging\log_message.inc}
  Query1.ParamByName('service').AsString := ServiceName+' / Fallback';
  for i := 1 to Query1.ParamCount - 1 do
    Query1.Params[i].AsString := '';

  i := 0;
  while i < Processed.Count do
  begin
    FieldName := '';
    FieldValue := '';
    if Pos('=', Processed[i]) > 0 then
    begin
      FieldName := Copy(Processed[i], 1, Pos('=', Processed[i]) - 1);
      FieldValue := TNetEncoding.URL.Decode(Copy(Processed[i], Pos('=', Processed[i]) + 1, Length(Processed[i])));
    end;

    // Filter out any junk, like when uploading a file via Swagger
    if FieldName <> '' then
    begin
      // Parse JSON of AddOns
      if FieldName = 'AddOns' then
      begin
//        MainForm.LogEvent('- '+FieldName+'='+FieldValue);
        AddOns := TJSONObject.ParseJSONValue(FieldValue) as TJSONObject;
        Query1.ParamByName('AddOns').AsString := Addons.toString;
      end

      // To= is assigned to ToNum field
      else if FieldName = 'To' then
      begin
//        MainForm.LogEvent('- '+FieldName+'='+FieldValue);
        Query1.ParamByName('ToNum').AsString := FieldValue;
      end

      // From= is assigned to FromNum field
      else if FieldName = 'From' then
      begin
//        MainForm.LogEvent('- '+FieldName+'='+FieldValue);
        Query1.ParamByName('FromNum').AsString := FieldValue;
      end

      // Process Other Fields
      else
      begin
//        MainForm.LogEvent('- '+FieldName+'='+FieldValue);
        if Query1.Params.FindParam(FieldName) <> nil then
        begin
          Query1.ParamByName(FieldName).AsString := FieldValue;
        end
        else
        begin
          MainForm.LogEvent('WARNING: Message Received with Unexpected Field: ');
          MainForm.LogEvent('[ '+Processed[i]+ ' ]');
        end;
      end;

    end;
    i := i + 1;
  end;

  // Log the fallback request
  try
    Query1.ExecSQL;
  except on E: Exception do
    begin
      MainForm.LogException('MessagingService.Fallback: Log Query', E.ClassName, E.Message, Query1.SQL.Text);
    end;
  end;

  // Returning XML, so flag it as such
  TXDataOperationContext.Current.Response.Headers.SetValue('content-type', 'text/xml');

  // Return an empty, but valid, response
  Result := TMemoryStream.Create;
  Response := TStringList.Create;
  Response.Add('<Response></Response>');
  Response.SaveToStream(Result);

  //Cleanup
  Request.Free;
  Processed.Free;
  Response.Free;

  // Keep track of endpoint history
  try
    {$Include sql\system\endpoint_history_insert\endpoint_history_insert.inc}
    Query1.ParamByName('PERSONID').AsInteger := 1;
    Query1.ParamByName('ENDPOINT').AsString := 'MessagingService.Fallback';
    Query1.ParamByName('ACCESSED').AsDateTime := TTimeZone.local.ToUniversalTime(ElapsedTime);
    Query1.ParamByName('IPADDRESS').AsString := TXDataOperationContext.Current.Request.RemoteIP;
    Query1.ParamByName('APPLICATION').AsString := MainForm.AppName;
    Query1.ParamByName('VERSION').AsString := MainForm.AppVersion;
    Query1.ParamByName('DATABASENAME').AsString := DatabaseName;
    Query1.ParamByName('DATABASEENGINE').AsString := DatabaseEngine;
    Query1.ParamByName('EXECUTIONMS').AsInteger := MillisecondsBetween(Now,ElapsedTime);
    Query1.ParamByName('DETAILS').AsString := '['+ServiceName+']';
    Query1.ExecSQL;
  except on E: Exception do
    begin
      MainForm.mmInfo.Lines.Add('['+E.Classname+'] '+E.Message);
      raise EXDataHttpUnauthorized.Create('Internal Error: M-C-EHI');
    end;
  end;

  // All Done
  try
    DBSupport.DisconnectQuery(DBConn, Query1);
  except on E: Exception do
    begin
      MainForm.mmInfo.Lines.Add('['+E.Classname+'] '+E.Message);
      raise EXDataHttpUnauthorized.Create('Internal Error: M-C-DQ');
    end;
  end;


end;

function TMessagingService.SendAMessage(MessageService: String; Destination: String; AMessage: String):TStream;
var  
  ServiceName: String;
  AccountNumber: String;
  AuthToken: String;
  SendURL: String;
  MessSys: TJSONArray;
  MessSysID: String;
  
  DBConn: TFDConnection;
  Query1: TFDQuery;
  DatabaseName: String;
  DatabaseEngine: String;
  ElapsedTime: TDateTime;
  User: IUserIdentity;
  JWT: String;
  
  Client: TNetHTTPClient;
  Request: TMultipartFormData;
  Response: String;
  Reply: TStringList;
  
  i: integer;
  ResultJSON: TJSONObject;
 
  procedure AddValue(ResponseValue: String; TableValue: String);
  begin
    if (ResultJSON.GetValue(ResponseValue) <> nil) and 
    not(ResultJSON.GetValue(ResponseValue) is TJSONNULL) then
    begin
      if (ResultJSON.GetValue(ResponseValue) is TJSONString) 
      then Query1.ParamByName(TableValue).AsString  := (ResultJSON.GetValue(ResponseValue) as TJSONString).Value
      else if (ResultJSON.GetValue(ResponseValue) is TJSONObject) 
      then Query1.ParamByName(TableValue).AsString  := (ResultJSON.GetValue(ResponseValue) as TJSONObject).ToString
      else if (ResultJSON.GetValue(ResponseValue) is TJSONNUMBER) 
      then Query1.ParamByName(TableValue).AsString  := FloatToStr((ResultJSON.GetValue(ResponseValue) as TJSONNumber).asDouble)
    end;
  end;
  
begin
  // Time this event
  ElapsedTime := Now;

  // Get Messaging System Configuration
  ServiceName := '';
  AccountNumber := '';
  AuthToken := '';
  SendURL := '';
  MessSysID := '';
  if (MainForm.AppConfiguration.GetValue('Messaging Services') <> nil) then
  begin
    if ((MainForm.AppConfiguration.GetValue('Messaging Services') as TJSONObject).GetValue('Twilio') <> nil) then
    begin
      if (((MainForm.AppConfiguration.GetValue('Messaging Services') as TJSONObject).GetValue('Twilio') as TJSONObject).GetValue('Service Name') <> nil) 
      then ServiceName := (((MainForm.AppConfiguration.GetValue('Messaging Services') as TJSONObject).GetValue('Twilio') as TJSONObject).GetValue('Service Name') as TJSONString).Value
      else raise EXDataHttpUnauthorized.Create('Invalid Messaging System Configuration: Service Name');
      
      if (((MainForm.AppConfiguration.GetValue('Messaging Services') as TJSONObject).GetValue('Twilio') as TJSONObject).GetValue('Auth Token') <> nil) 
      then AuthToken := (((MainForm.AppConfiguration.GetValue('Messaging Services') as TJSONObject).GetValue('Twilio') as TJSONObject).GetValue('Auth Token') as TJSONString).Value
      else raise EXDataHttpUnauthorized.Create('Invalid Messaging System Configuration: Auth Token');

      if (((MainForm.AppConfiguration.GetValue('Messaging Services') as TJSONObject).GetValue('Twilio') as TJSONObject).GetValue('Account') <> nil) 
      then AccountNumber := (((MainForm.AppConfiguration.GetValue('Messaging Services') as TJSONObject).GetValue('Twilio') as TJSONObject).GetValue('Account') as TJSONString).Value
      else raise EXDataHttpUnauthorized.Create('Invalid Messaging System Configuration: Account');

      if (((MainForm.AppConfiguration.GetValue('Messaging Services') as TJSONObject).GetValue('Twilio') as TJSONObject).GetValue('Send URL') <> nil) 
      then SendURL := (((MainForm.AppConfiguration.GetValue('Messaging Services') as TJSONObject).GetValue('Twilio') as TJSONObject).GetValue('Send URL') as TJSONString).Value
      else raise EXDataHttpUnauthorized.Create('Invalid Messaging System Configuration: Send URL');

      if (((MainForm.AppConfiguration.GetValue('Messaging Services') as TJSONObject).GetValue('Twilio') as TJSONObject).GetValue('Messaging Services') <> nil) then
      begin
        MessSys := ((MainForm.AppConfiguration.GetValue('Messaging Services') as TJSONObject).GetValue('Twilio') as TJSONObject).GetValue('Messaging Services') as TJSONArray;
        i := 0;
        while i < MessSys.Count - 1 do
        begin
          if (MessSys.Items[i] as TJSONObject).GetValue(MessageService) <> nil
          then MessSysID := ((MessSys.Items[i] as TJSONObject).GetValue(MessageService) as TJSONString).Value;
          i := i + 1;
        end;
        if (MessSysID = '') 
        then raise EXDataHttpUnauthorized.Create('Invalid Messaging System Configuration: Messaging Service Not Found');
      end;
    end;
  end;
  if (ServiceName = '') or (AccountNumber = '') or (AuthToken = '') or (SendURL = '') or (MessSysID = '')
  then raise EXDataHttpUnauthorized.Create('Invalid Messaging System Configuration');

//  MainForm.LogEvent('Service: '+ServiceName);
//  MainForm.LogEvent('Account: '+AccountNumber);
//  MainForm.LogEvent('AuthTok: '+AuthToken);
//  MainForm.LogEvent('SendURL: '+SendURL);
//  MainForm.LogEvent('MessSys: '+MessSysId);
  
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
      raise EXDataHttpUnauthorized.Create('Internal Error: M-SAM-CQ');
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
      raise EXDataHttpUnauthorized.Create('Internal Error: M-SAM-JC');
    end;
  end;
  if Query1.RecordCount <> 1 then
  begin
    DBSupport.DisconnectQuery(DBConn, Query1);
    raise EXDataHttpUnauthorized.Create('JWT was not validated');
  end;


  // Prepare the Connection
  Client := TNetHTTPClient.Create(nil);
  client.Asynchronous := False;
  Client.ConnectionTimeout := 30000; // 30 secs
  Client.ResponseTimeout := 30000; // 30 secs
//  Client.ContentType := 'application/x-www-form-urlencoded"';
  Client.CustomHeaders['Authorization'] := 'Basic '+TIdEncoderMIME.EncodeBytes(ToBytes(AccountNumber+':'+AuthToken));
  Client.SecureProtocols := [THTTPSecureProtocol.SSL3, THTTPSecureProtocol.TLS12];
  
  // Prepare the Request
  Request := TMultipartFormData.Create();
  Request.AddField('To',Destination);
  Request.AddField('MessagingServiceSid', MessSysID);
  Request.AddField('Body', AMessage);

  // Submit Request
  try
    Response := Client.Post( SendURL, Request ).ContentAsString(TEncoding.UTF8);
  except on E: Exception do
    begin
      MainForm.LogException('Send A Message [ '+ServiceName+' ]',E.ClassName, E.Message, Destination);
    end;
  end;

  
  // Prepare Response
//  MainForm.LogEvent(Response);
  ResultJSON := TJSONObject.ParseJSONValue(Response) as TJSONObject;

   
  // Use this query to log messages. Set parameters to null string to start
  try
    {$Include sql\messaging\messaging\log_message.inc}
    Query1.ParamByName('service').AsString := ServiceName;
    for i := 1 to Query1.ParamCount - 1 do
      Query1.Params[i].AsString := '';
  except on E: Exception do
    begin
      MainForm.LogException('MessagingService.SendAMessage: Log Query Prep', E.ClassName, E.Message, Query1.SQL.Text);
    end;
  end;

  // Pick out the values from the Response JSON that match our Messaging table columns as best we can - the incoming JSON can change at any time!
  try
    AddValue('status',                'SmsStatus'           );
    AddValue('error_message',         'ErrorMessage'        );
    AddValue('error_code',            'ErrorCode'           );
    AddValue('direction',             'Direction'           );
    AddValue('account_sid',           'AccountSid'          );
    AddValue('sid',                   'SmsSid'              );
    AddValue('sid',                   'MessageSid'          );
    AddValue('messaging_service_sid', 'MessagingServiceSid' );
    AddValue('body',                  'Body'                );
    AddValue('to',                    'ToNum'               );
    AddValue('from',                  'FromNum'             );
    AddValue('num_segments',          'NumSegments'         );
    AddValue('num_media',             'NumMedia'            );
    AddValue('price',                 'Price'               );
    AddValue('price_unit',            'PriceUnit'           );
    AddValue('uri',                   'Uri'                 );
    AddValue('subresource_uris',      'Resource'            );
    AddValue('api_version',           'ApiVersion'          );
  except on E: Exception do
    begin
      MainForm.LogException('MessagingService.SendAMessage: Log Query Pop', E.ClassName, E.Message, Query1.SQL.Text);
    end;
  end;
  
  // Log the send response (which includes the original message)
  try
    Query1.ExecSQL;
  except on E: Exception do
    begin
      MainForm.LogException('MessagingService.SendAMessage: Log Query', E.ClassName, E.Message, Query1.SQL.Text);
    end;
  end;

  // Send back a response
  Result := TMemoryStream.Create;
  Reply := TStringList.Create;
  Reply.Add(ResultJSON.ToString);
  Reply.SaveToStream(Result);
  
  // Keep track of endpoint history
  try
    {$Include sql\system\endpoint_history_insert\endpoint_history_insert.inc}
    Query1.ParamByName('PERSONID').AsInteger := User.Claims.Find('usr').AsInteger;
    Query1.ParamByName('ENDPOINT').AsString := 'MessagingService.SendAMessage';
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
      DBSupport.DisconnectQuery(DBConn, Query1);
      MainForm.mmInfo.Lines.Add('['+E.Classname+'] '+E.Message);
      raise EXDataHttpUnauthorized.Create('Internal Error: M-SAM-EHI');
    end;
  end;

  // Cleanup
  Request.Free;
  Reply.Free;
  ResultJSON.Free;

  // All Done
  try
    DBSupport.DisconnectQuery(DBConn, Query1);
  except on E: Exception do
    begin
      MainForm.mmInfo.Lines.Add('['+E.Classname+'] '+E.Message);
      raise EXDataHttpUnauthorized.Create('Internal Error: M-SAM-DQ');
    end;
  end;
end;

initialization
  RegisterServiceType(TMessagingService);

end.
