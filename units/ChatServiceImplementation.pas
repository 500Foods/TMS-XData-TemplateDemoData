unit ChatServiceImplementation;

interface

uses
  System.Classes,
  System.SysUtils,
  System.JSON,
  System.DateUtils,

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
    function Chat(Conversation:String; Context: String; ChatID: String):TStream;
  end;

implementation

uses Unit2;

function TChatService.Chat(Conversation, Context: String; ChatID: String): TStream;
var
  Client: TNetHTTPClient;
  Response: String;
  Request: TStringStream;
begin

  // Do we have enough information to process this request?
  if (MainForm.AppConfiguration.GetValue('Chat Interface') as TJSONObject) = nil
  then raise EXDataHttpUnauthorized.Create('Chat Service is Unavailable.');

  if ((MainForm.AppConfiguration.getValue('Chat Interface') as TJSONObject).getValue('API Key') as TJSONString) = nil
  then raise EXDataHttpUnauthorized.Create('Chat Service Error: Missing API Key');

  if ((MainForm.AppConfiguration.getValue('Chat Interface') as TJSONObject).getValue('Chat Endpoint') as TJSONString) = nil
  then raise EXDataHttpUnauthorized.Create('Chat Service Error: Missing Endpoint URL');

  if ((MainForm.AppConfiguration.getValue('Chat Interface') as TJSONObject).getValue('Organization') as TJSONString) = nil
  then raise EXDataHttpUnauthorized.Create('Chat Service Error: Missing Organization');

  if ((MainForm.AppConfiguration.getValue('Chat Interface') as TJSONObject).getValue('Model') as TJSONString) = nil
  then raise EXDataHttpUnauthorized.Create('Chat Service Error: Missing Model');

  // Returning JSON, so flag it as such
  TXDataOperationContext.Current.Response.Headers.SetValue('content-type', 'application/json');

  MainForm.mmInfo.Lines.Add('Conversation: '+Conversation);
  MainForm.mmInfo.Lines.Add('Context: '+Context);
  MainForm.mmInfo.Lines.Add('ChatID: '+ChatID);
  MainForm.mmInfo.Lines.Add('API Key: '+(((MainForm.AppConfiguration.getValue('Chat Interface') as TJSONObject).GetValue('API Key') as TJSONString).Value));
  MainForm.mmInfo.Lines.Add('Chat API: '+(((MainForm.AppConfiguration.getValue('Chat Interface') as TJSONObject).GetValue('Chat Endpoint') as TJSONString).Value));
  MainForm.mmInfo.Lines.Add('Organization: '+(((MainForm.AppConfiguration.getValue('Chat Interface') as TJSONObject).GetValue('Organization') as TJSONString).Value));
  MainForm.mmInfo.Lines.Add('Model: '+(((MainForm.AppConfiguration.getValue('Chat Interface') as TJSONObject).GetValue('Model') as TJSONString).Value));

  Client := TNetHTTPClient.Create(nil);
  client.Asynchronous := False;
  Client.ConnectionTimeout := 60000; // 1 min
  Client.ResponseTimeout := 60000; // 1 min
  Client.ContentType := 'application/json';
  Client.SecureProtocols := [THTTPSecureProtocol.SSL3, THTTPSecureProtocol.TLS12];
  Client.CustomHeaders['Authorization'] := 'Bearer '+(((MainForm.AppConfiguration.getValue('Chat Interface') as TJSONObject).GetValue('API Key') as TJSONString).Value);
  Client.CustomHeaders['OpenAI-Organization'] := (((MainForm.AppConfiguration.getValue('Chat Interface') as TJSONObject).GetValue('Organization') as TJSONString).Value);

  Request := TStringStream.Create('{'+
    '"model":"'+(((MainForm.AppConfiguration.GetValue('Chat Interface') as TJSONObject).GetValue('Model') as TJSONString).Value)+'",'+
    '"messages":[{"role":"user","content":"'+Conversation+'"}]'+
    '}');
  MainForm.mmInfo.Lines.Add(Request.DataString);
  try
    Response := Client.Post(
      ((MainForm.AppConfiguration.getValue('Chat Interface') as TJSONObject).GetValue('Chat Endpoint') as TJSONString).Value,
      Request
    ).ContentAsString;
   except on E: Exception do
     begin
       MainForm.mmInfo.LInes.Add('[ '+E.ClassName+' ] '+E.Message);
     end;
   end;

  Result := TStringStream.Create(Response);
  Request.Free;
end;


initialization
  RegisterServiceType(TChatService);

end.
