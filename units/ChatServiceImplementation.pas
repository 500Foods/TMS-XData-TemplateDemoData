unit ChatServiceImplementation;

interface

uses
  System.Classes,
  System.SysUtils,
  System.JSON,
  System.DateUtils,
  System.StrUtils,
  System.IOUtils,
  System.NetEncoding,
  System.Generics.Collections,

  VCL.Graphics,
  Vcl.Imaging.pngimage,

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


  ChatService;

type
  [ServiceImplementation]
  TChatService = class(TInterfacedObject, IChatService)
  private
    function Chat(Model: String; Conversation: String; Context: String; Choices: Integer; ChatID: String):TStream;
    function GetChatInformation:TStream;
    function GetChatImage(F: String):TStream;
    function TrimConversation(var Conversation: String; var Context: String; Limit: Integer):String;
  end;

implementation

uses Unit2, Unit3;

function TChatService.Chat(Model: String; Conversation: String; Context: String; Choices: Integer; ChatID: String):TStream;
var
  Client: TNetHTTPClient;
  Response: String;
  Request: TStringStream;
  ModelJSON: TJSONObject;
  i: integer;
  TrimMessage: String;
  ResultJSON: TJSONObject;
  ImagePrompt: String;
  ImageSize: String;
  Cost: Double;

  DBConn: TFDConnection;
  Query1: TFDQuery;
  DatabaseName: String;
  DatabaseEngine: String;
  ElapsedTime: TDateTime;
  User: IUserIdentity;
  JWT: String;

begin

  // Time this event
  ElapsedTime := Now;
  Request := nil;
  ModelJSON := nil;

  // Is the chat service available?
  if (MainForm.AppConfiguration.GetValue('Chat Interface') as TJSONArray) = nil
  then raise EXDataHttpUnauthorized.Create('Chat Service is Unavailable.');

  // Find the matching model
  i := 0;
  while i <  (MainForm.AppConfiguration.GetValue('Chat Interface') as TJSONArray).Count do
  begin
    if ((MainForm.AppConfiguration.GetValue('Chat Interface') as TJSONArray).Items[i] as TJSONObject).GetValue('Name') <> nil then
    begin
      if Trim(Uppercase((((MainForm.AppConfiguration.GetValue('Chat Interface') as TJSONArray).Items[i] as TJSONObject).GetValue('Name') as TJSONString).Value)) = Trim(Uppercase(Model)) then
      begin
        ModelJSON := (MainForm.AppConfiguration.GetValue('Chat Interface') as TJSONArray).Items[i] as TJSONObject;
      end;
    end;
    i := i + 1;
  end;

  // Do we have enough information to process this request?
  if ModelJSON = nil
  then raise EXDataHttpUnauthorized.Create('Chat Service Error: Model Not Found [ '+Model+' ]');

  if ModelJSON.GetValue('Model') = nil
  then raise EXDataHttpUnauthorized.Create('Chat Service Error: Missing Model');

  if ModelJSON.GetValue('Organization') = nil
  then raise EXDataHttpUnauthorized.Create('Chat Service Error: Missing Organization');

  if ModelJSON.GetValue('API Key') = nil
  then raise EXDataHttpUnauthorized.Create('Chat Service Error: Missing API Key');

  if ModelJSON.GetValue('Endpoint') = nil
  then raise EXDataHttpUnauthorized.Create('Chat Service Error: Missing Endpoint URL');

  if ModelJSON.GetValue('Limit') = nil
  then raise EXDataHttpUnauthorized.Create('Chat Service Error: Missing Limit');

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
  if Query1.RecordCount <> 1 then
  begin
    DBSupport.DisconnectQuery(DBConn, Query1);
    raise EXDataHttpUnauthorized.Create('JWT was not validated');
  end;

  // Returning JSON, so flag it as such
  TXDataOperationContext.Current.Response.Headers.SetValue('content-type', 'application/json');

//  MainForm.mmInfo.Lines.Add('Model Name: '+Model);
//  MainForm.mmInfo.Lines.Add('Conversation: '+Conversation);
//  MainForm.mmInfo.Lines.Add('Context: '+Context);
//  MainForm.mmInfo.Lines.Add('Choices: '+IntToStr(Choices));
//  MainForm.mmInfo.Lines.Add('ChatID: '+ChatID);
//  MainForm.mmInfo.Lines.Add('Model: '+((ModelJSON.GetValue('Model') as TJSONString).Value));
//  MainForm.mmInfo.Lines.Add('API Key: '+((ModelJSON.GetValue('API Key') as TJSONString).Value));
//  MainForm.mmInfo.Lines.Add('Endpoint: '+((ModelJSON.GetValue('Endpoint') as TJSONString).Value));
//  MainForm.mmInfo.Lines.Add('Organization: '+((ModelJSON.GetValue('Organization') as TJSONString).Value));

  // Prepare the request
  Client := TNetHTTPClient.Create(nil);
  client.Asynchronous := False;
  Client.ConnectionTimeout := 300000; // 5 min
  Client.ResponseTimeout := 300000; // 5 min
  Client.ContentType := 'application/json';
  Client.SecureProtocols := [THTTPSecureProtocol.SSL3, THTTPSecureProtocol.TLS12];
  Client.CustomHeaders['Authorization'] := 'Bearer '+((ModelJSON.GetValue('API Key') as TJSONString).Value);
  Client.CustomHeaders['OpenAI-Organization'] := ((ModelJSON.GetValue('Organization') as TJSONString).Value);

  // Prepare Conversation
  if Copy(Trim(Conversation),1,1) <> '"'
  then Conversation := '"'+Trim(Conversation)+'"';

  // Prepare Context for Chat
  if Pos('CHAT',Uppercase(Model)) > 0 then
  begin
    {$Include sql\ai\chatai\log_chatai.inc}
    Query1.ParamByName('CHATID').AsString := ChatID;
    Query1.ParamByName('LASTMODIFIED').AsDateTime := TTimeZone.local.ToUniversalTime(ElapsedTime);
    Query1.ParamByName('LASTMODIFIER').AsInteger :=  User.Claims.Find('usr').AsInteger;
    Query1.ParamByName('MODEL').AsString := Model;
    Query1.ParamByName('CONVERSATION').AsString := Conversation;
    Query1.ParamByName('CONTEXT').AsString := Context;

    TrimMessage := TrimConversation(Conversation, Context, ((ModelJSON.GetValue('Limit') as TJSONNumber).AsInt));

    // Without Context (initial conversation, or excessive context)
    if ((Context = '') or (Context = 'None')) then
    begin
      Request := TStringStream.Create('{'+
          '"model":"'+((ModelJSON.GetValue('Model') as TJSONString).Value)+'",'+
          '"messages":['+'{"role":"user","content":'+Conversation+'}]'+
       '}');
    end

    // With Context
    else
    begin
      Request := TStringStream.Create('{'+
          '"model":"'+((ModelJSON.GetValue('Model') as TJSONString).Value)+'",'+
          '"messages":['+Context+',{"role":"user","content":'+Conversation+'}]'+
        '}');
    end;
  end;

  // Prepare Image request
  if Pos('IMAGE',Uppercase(Model)) > 0 then
  begin
    ImagePrompt := Copy(Conversation,1,(ModelJSON.GetValue('Limit') as TJSONNumber).AsInt);
    ImageSize := '256x256';
    if Pos('512',Model) > 0 then ImageSize := '512x512';
    if Pos('1024',Model) > 0 then ImageSize := '1024x1024';

    Request := TStringStream.Create('{'+
        '"prompt":'+ImagePrompt+','+
        '"size":"'+ImageSize+'",'+
        '"n":'+IntToStr(Choices)+','+
        '"response_format":"b64_json"'+
      '}');

  end;

  // Submit Request
  try
    Response := Client.Post(
        (ModelJSON.GetValue('Endpoint') as TJSONString).Value,
        Request
      ).ContentAsString(TEncoding.UTF8);

  except on E: Exception do
    begin
      MainForm.mmInfo.LInes.Add('[ '+E.ClassName+' ] '+E.Message);
    end;
  end;

  // Prepare Response
  ResultJSON := TJSONObject.ParseJSONValue(Response) as TJSONObject;


  // Log Chat Conversation
  if Pos('CHAT',Uppercase(Model)) > 0 then
  begin
    if (ResultJSON <> nil) and
       (ResultJSON.GetValue('model') <> nil) and
       (ResultJSON.GetValue('choices') <> nil) and
       (ResultJSON.GetValue('usage') <> nil) then
    begin
      try
        Query1.ParamByName('MODELACTUAL').AsString := (ResultJSON.GetValue('model') as TJSONString).Value;
        Query1.ParamByName('COSTPROMPT').AsFloat := (ModelJSON.GetValue('Cost Prompt') as TJSONNumber).AsDouble * ((ResultJSON.GetValue('usage') as TJSONObject).GetValue('prompt_tokens') as TJSONNumber).AsInt;
        Query1.ParamByName('COSTCOMPLETION').AsFloat := (ModelJSON.GetValue('Cost Completion') as TJSONNumber).AsDouble * ((ResultJSON.GetValue('usage') as TJSONObject).GetValue('completion_tokens') as TJSONNumber).AsInt;
        Cost := ((ModelJSON.GetValue('Cost Prompt') as TJSONNumber).AsDouble * ((ResultJSON.GetValue('usage') as TJSONObject).GetValue('prompt_tokens') as TJSONNumber).AsInt)+
                ((ModelJSON.GetValue('Cost Completion') as TJSONNumber).AsDouble * ((ResultJSON.GetValue('usage') as TJSONObject).GetValue('completion_tokens') as TJSONNumber).AsInt);
        Query1.ParamByName('COSTTOTAL').AsFloat := Cost;
        Query1.ParamByName('TOKENPROMPT').AsInteger := ((ResultJSON.GetValue('usage') as TJSONObject).getValue('prompt_tokens') as TJSONNumber).AsInt;
        Query1.ParamByName('TOKENCOMPLETION').AsInteger := ((ResultJSON.GetValue('usage') as TJSONObject).getValue('completion_tokens') as TJSONNumber).AsInt;
        Query1.ParamByName('TOKENTOTAL').AsInteger := ((ResultJSON.GetValue('usage') as TJSONObject).getValue('total_tokens') as TJSONNumber).AsInt;
        Query1.ParamByName('RESPONSE').AsString := ((((ResultJSON.GetValue('choices') as TJSONArray).Items[0] as TJSONObject).GetValue('message') as TJSONObject).GetValue('content') as TJSONString).Value;
        Query1.ParamByName('REASON').AsString := TrimMessage+'/'+(((ResultJSON.GetValue('choices') as TJSONArray).Items[0] as TJSONObject).GetValue('finish_reason') as TJSONString).Value;
        Query1.ExecSQL;
      except on E: Exception do
        begin
          MainForm.mmInfo.Lines.Add('['+E.Classname+'] '+E.Message);
          raise EXDataHttpUnauthorized.Create('Internal Error: LCAI');
        end;
      end;
    end;
  end;


  // Log Image
  if Pos('IMAGE',Uppercase(Model)) > 0 then
  begin
    Cost := Choices * (ModelJSON.GetValue('Cost') as TJSONNumber).AsDouble;

    if (ResultJSON <> nil) and
       (ResultJSON.GetValue('data') <> nil) then
    begin
      {$Include sql\ai\imageai\log_imageai.inc}
      for i := 0 to (ResultJSON.GetValue('data') as TJSONArray).Count-1 do
      begin
       try
          Query1.ParamByName('CHATID').AsString := ChatID+'-'+IntToStr(i);
          Query1.ParamByName('LASTMODIFIED').AsDateTime := TTimeZone.local.ToUniversalTime(ElapsedTime);
          Query1.ParamByName('LASTMODIFIER').AsInteger :=  User.Claims.Find('usr').AsInteger;
          Query1.ParamByName('MODEL').AsString := Model;
          Query1.ParamByName('MODELACTUAL').AsString := Model;
          Query1.ParamByName('COSTTOTAL').AsFloat := (ModelJSON.GetValue('Cost') as TJSONNumber).AsDouble;
          Query1.ParamByName('PROMPT').AsString := Conversation;
          Query1.ParamByName('GENERATEDIMAGE').AsString := '<img src="data:image/png;base64,'+(((ResultJSON.GetValue('data') as TJSONArray).Items[i] as TJSONObject).GetValue('b64_json') as TJSONString).Value+'">';
          Query1.ExecSQL;
        except on E: Exception do
          begin
            MainForm.mmInfo.Lines.Add('['+E.Classname+'] '+E.Message);
            raise EXDataHttpUnauthorized.Create('Internal Error: LIAI');
          end;
        end;
      end;
    end;
  end;

  // Add details about whether anything was altered, as well as the cost of the request
  ResultJSON.AddPair('Trim Message',TrimMessage);
  ResultJSON.AddPair('Cost',FloatToStrF(Cost,ffNumber,5,4));

  // Response is ready
  Result := TStringStream.Create(ResultJSON.ToString, TEncoding.UTF8);

  // Keep track of endpoint history
  try
    {$Include sql\system\endpoint_history_insert\endpoint_history_insert.inc}
    Query1.ParamByName('PERSONID').AsInteger := User.Claims.Find('usr').AsInteger;
    Query1.ParamByName('ENDPOINT').AsString := 'ChatService.Chat';
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

  // Cleanup
  Request.Free;
  ResultJSON.Free;
end;


function TChatService.GetChatImage(F: String): TStream;
var
  CacheFolder: String;
  CacheFile: String;
  CacheFileThumb: String;

  SearchIndex: String;
  SearchFile: String;
  SearchStatus: String;

  ReturnThumb: Boolean;

  DBConn: TFDConnection;
  Query1: TFDQuery;
  DatabaseName: String;
  DatabaseEngine: String;
  ElapsedTime: TDateTime;

  ImageString: String;
  ImageBytes: TBytes;
  ImageThumb: TPNGImage;
  ImageBitmap: TBitmap;

begin
  ElapsedTime := Now;
  SearchStatus := 'Unknown';

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
      raise EXDataHttpUnauthorized.Create('Internal Error: CQ');
    end;
  end;

  // Returning an Image, so flag it as such
  TXDataOperationContext.Current.Response.Headers.SetValue('content-type', 'image/png');

  // These don't really expire, so set cache to one year
  TXDataOperationContext.Current.Response.Headers.SetValue('cache-control', 'max-age=31536000');

  // Where is the Cache?
  CacheFolder := MainForm.AppCacheFolder+'images/ai/';

  // Is a Thumb being requested?
  SearchIndex := StringReplace(F, '_tn.png','',[]);
  SearchIndex := StringReplace(SearchIndex, '.png','',[]);
  CacheFile := CacheFolder + Copy(SearchIndex,Length(SearchIndex)-5,3) + '/' + SearchIndex + '.png';
  CacheFileThumb := CacheFolder + Copy(SearchIndex,Length(SearchIndex)-5,3) + '/' + SearchIndex + '_tn.png';
  if Pos('_tn.', F) > 0 then
  begin
    ReturnThumb := True;
    SearchFile := CacheFileThumb;
  end
  else
  begin
    ReturnThumb := False;
    SearchFile := CacheFile;
  end;

  // We've got a cache hit
  if FileExists(SearchFile) then
  begin
    SearchStatus := 'Hit';
    Result := TFileStream.Create(CacheFile, fmOpenRead);
  end

  // Cache miss
  else
  begin
    SearchStatus := 'Miss';

    // Retrieve Image from Database
    {$Include sql\ai\imageai\imageai_retrieve.inc}

    // If thumbnail is requested, that's fine, but the original is what is stored in the database
    // so let's get that first, and then generate the image and thumbnail cache, and then return whatever
    // was originally requested.
    Query1.ParambyName('CHATID').AsString := SearchIndex;
    try
      Query1.Open;
    except on E: Exception do
      begin
        MainForm.mmInfo.Lines.Add('['+E.Classname+'] '+E.Message);
        DBSupport.DisconnectQuery(DBConn, Query1);
        raise EXDataHttpUnauthorized.Create('Internal Error: IAIR');
      end;
    end;

    if (Query1.RecordCount <> 1) then
    begin
      DBSupport.DisconnectQuery(DBConn, Query1);
      raise EXDataHttpUnauthorized.Create('Image Not Found.');
    end;

    // Generate Regular Cache Entry - Decode Base64 Image
    ImageString := Query1.FieldByName('generated_image').AsString;
    ImageBytes := TNetEncoding.Base64.DecodeStringToBytes(Copy(ImageString,33,length(ImageString)-34));

    // Return binary file as the result
    Result := TMemoryStream.Create;
    Result.WriteBuffer(Pointer(ImageBytes)^, Length(ImageBytes));

    // Save the binary file to the cache
    if (ForceDirectories(System.IOUtils.TPath.GetDirectoryName(CacheFile)))
    then (Result as TMemoryStream).SaveToFile(CacheFile);

    // Create a thumbnail version: File > PNG > BMP > PNG > File
    ImageThumb := TPNGImage.Create;
    ImageThumb.LoadFromFile(CacheFile);
    ImageBitmap := TBitmap.Create;
    ImageBitmap.width := 92;
    ImageBitmap.height := 92;
    ImageBitmap.Canvas.StretchDraw(Rect(0,0,92,92), ImageThumb);
    ImageThumb.assign(ImageBitmap);

    ImageThumb.SaveToFile(CacheFileThumb);

    if ReturnThumb
    then (Result as TMemoryStream).LoadFromFile(CacheFileThumb);

    ImageThumb.Free;
    ImageBitmap.Free;
  end;


  // Keep track of endpoint history
  try
    {$Include sql\system\endpoint_history_insert\endpoint_history_insert.inc}
    Query1.ParamByName('PERSONID').AsInteger := 1; // Default admin user
    Query1.ParamByName('ENDPOINT').AsString := 'ChatService.GetChatImage';
    Query1.ParamByName('ACCESSED').AsDateTime := TTimeZone.local.ToUniversalTime(ElapsedTime);
    Query1.ParamByName('IPADDRESS').AsString := TXDataOperationContext.Current.Request.RemoteIP;
    Query1.ParamByName('APPLICATION').AsString := MainForm.AppName;
    Query1.ParamByName('VERSION').AsString := MainForm.AppVersion;
    Query1.ParamByName('DATABASENAME').AsString := DatabaseName;
    Query1.ParamByName('DATABASEENGINE').AsString := DatabaseEngine;
    Query1.ParamByName('EXECUTIONMS').AsInteger := MillisecondsBetween(Now,ElapsedTime);
    Query1.ParamByName('DETAILS').AsString := '['+F+']['+SearchStatus+']';
    Query1.ExecSQL;
  except on E: Exception do
    begin
      MainForm.mmInfo.Lines.Add('['+E.Classname+'] '+E.Message);
      DBSupport.DisconnectQuery(DBConn, Query1);
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

function TChatService.GetChatInformation: TStream;
var
  i: Integer;
  Response: TJSONObject;
  ResultArray: TJSONArray;
  Models: TJSONArray;

  DBConn: TFDConnection;
  Query1: TFDQuery;
  DatabaseName: String;
  DatabaseEngine: String;
  ElapsedTime: TDateTime;
  User: IUserIdentity;
  JWT: String;
  URL: String;

begin
  ElapsedTime := Now;

  // For image links, we'll need to point them to the GetChatImage Endpoint
  URL := TXdataOperationContext.current.Request.URI.AbsoluteURI;
  URL := Copy(URL,1,Pos('GetChatInformation',URL)-1)+'GetChatImage?F=';

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
  if Query1.RecordCount <> 1 then
  begin
    DBSupport.DisconnectQuery(DBConn, Query1);
    raise EXDataHttpUnauthorized.Create('JWT was not validated');
  end;

  // Returning JSON, so flag it as such
  TXDataOperationContext.Current.Response.Headers.SetValue('content-type', 'application/json');

  // Emtpy to begin with
  Response := TJSONObject.Create;

  // Are chat services avialable?
  if (MainForm.AppConfiguration.GetValue('Chat Interface') as TJSONArray) = nil
  then Response.AddPair('Chat','UNAVAILABLE')
  else
  begin
    i := 0;
    Models := TJSONArray.Create;
    while i < (MainForm.AppConfiguration.GetValue('Chat Interface') as TJSONArray).Count do
    begin
      if (((MainForm.AppConfiguration.GetValue('Chat Interface') as TJSONArray).items[i] as TJSONObject).getValue('Default') <> nil) and
         ((((MainForm.AppConfiguration.GetValue('Chat Interface') as TJSONArray).items[i] as TJSONObject).getValue('Default') as TJSONBool).AsBoolean = True)
      then
      begin
        Models.Add('*** '+(((MainForm.AppConfiguration.GetValue('Chat Interface') as TJSONArray).items[i] as TJSONObject).getValue('Name') as TJSONString).Value);
      end
      else
      begin
        Models.Add((((MainForm.AppConfiguration.GetValue('Chat Interface') as TJSONArray).items[i] as TJSONObject).getValue('Name') as TJSONString).Value);
      end;
      i := i + 1;
    end;
    Response.AddPair('Models',Models);
  end;

 // Get ChatAI Usage Statistics
  try
    {$Include sql\ai\chatai\chatai_usage.inc}
    Query1.Open;
  except on E: Exception do
    begin
      MainForm.mmInfo.Lines.Add('['+E.Classname+'] '+E.Message);
      raise EXDataHttpUnauthorized.Create('Internal Error: ChatAI Usage');
    end;
  end;
  ResultArray := TJSONObject.ParseJSONValue(DBSupport.QueryToJSON(Query1)) as TJSONArray;
  Response.AddPair('ChatAI Usage', ResultArray);

 // Get ChatAI Recent
  try
    {$Include sql\ai\chatai\chatai_recent.inc}
    Query1.Open;
  except on E: Exception do
    begin
      MainForm.mmInfo.Lines.Add('['+E.Classname+'] '+E.Message);
      raise EXDataHttpUnauthorized.Create('Internal Error: ChatAI Recent');
    end;
  end;
  ResultArray := TJSONObject.ParseJSONValue(DBSupport.QueryToJSON(Query1)) as TJSONArray;
  Response.AddPair('ChatAI Recent', ResultArray);

 // Get ImageAI Usage Statistics
  try
    {$Include sql\ai\imageai\imageai_usage.inc}
    Query1.Open;
  except on E: Exception do
    begin
      MainForm.mmInfo.Lines.Add('['+E.Classname+'] '+E.Message);
      raise EXDataHttpUnauthorized.Create('Internal Error: ImageAI Usage');
    end;
  end;
  ResultArray := TJSONObject.ParseJSONValue(DBSupport.QueryToJSON(Query1)) as TJSONArray;
  Response.AddPair('ImageAI Usage', ResultArray);

 // Get ImageAI Recent
  try
    {$Include sql\ai\imageai\imageai_recent.inc}
    Query1.ParamByName('URL').AsString := URL;
    Query1.Open;
  except on E: Exception do
    begin
      MainForm.mmInfo.Lines.Add('['+E.Classname+'] '+E.Message);
      raise EXDataHttpUnauthorized.Create('Internal Error: ImageAI Recent');
    end;
  end;
  ResultArray := TJSONObject.ParseJSONValue(DBSupport.QueryToJSON(Query1)) as TJSONArray;
  Response.AddPair('ImageAI Recent', ResultArray);

  Result := TStringStream.Create(Response.ToString);

  // Keep track of endpoint history
  try
    {$Include sql\system\endpoint_history_insert\endpoint_history_insert.inc}
    Query1.ParamByName('PERSONID').AsInteger := User.Claims.Find('usr').AsInteger;
    Query1.ParamByName('ENDPOINT').AsString := 'ChatService.GetChatInformation';
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

  // Cleanup
  Response.Free;

end;


function TChatService.TrimConversation(var Conversation, Context: String; Limit: Integer):String;
var
  LimitChars: Integer;
  Started: Integer;
  Clipped: Integer;
  i: Integer;
  ContextJSON: TJSONArray;
begin
  LimitChars := Limit * 2; // 3 seems to not give enough room for basic responses
  ContextJSON := nil;

//  MainForm.mmInfo.Lines.Add('Trim Start: '+IntToStr(LimitChars)+' limit, '+IntToStr(Length(Conversation))+' conv, '+IntToStr(Length(Context))+' ctx.');

  // Our conversation is so long that there is no room for context.
  if length(Conversation) > LimitChars then
  begin
    Conversation := Copy(Conversation, 1, LimitChars);
    Context := '';
    Result := 'Conversation Clipped';
  end
  else if (Length(Conversation) + Length(Context)) > LimitChars then
  begin
    try
      ContextJSON := TJSONObject.ParseJSONValue('['+Context+']') as TJSONArray;
    except on E: Exception do
      begin
        Context := '';
      end
    end;

    Started := 0;
    Clipped := 0;
    if ((ContextJSON <> nil) and (ContextJSON.Count > 0)) then
    begin
      Started := ContextJSON.Count;
      i := 0;
      while i < ContextJSON.Count do
      begin
        if (Length(Conversation) + Length(Context)) > LimitChars then
        begin
          // Remove entry from the beginning of the array
          ContextJSON.Remove(0);
          Clipped := Clipped + 1;
          Context := Copy(ContextJSON.ToString,2,Length(ContextJSON.ToString)-2);
        end;
        i := i + 1;
      end;
    end;

//    if (Length(Conversation) + Length(Context)) > LimitChars then
//    begin
//      Clipped := Started;
//      Context := '';
//    end;

    Result := 'Context Clipped '+IntToStr(Clipped)+' of '+IntToStr(Started);

    ContextJSON.Free;

  end
  else
  begin
    Result := 'Normal';
  end;

//  MainForm.mmInfo.Lines.Add('Trim End: '+IntToStr(LimitChars)+' limit, '+IntToStr(Length(Conversation))+' conv, '+IntToStr(Length(Context))+' ctx: '+Result);
//  MainForm.mmInfo.Lines.Add('Context: '+Context);

end;



initialization
  RegisterServiceType(TChatService);

end.
