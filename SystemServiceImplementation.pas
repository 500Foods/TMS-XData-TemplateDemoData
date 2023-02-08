unit SystemServiceImplementation;

interface

uses
  System.Classes,
  System.SysUtils,
  System.JSON,
  System.DateUtils,
  XData.Server.Module,
  XData.Service.Common,
  SystemService;

type
  [ServiceImplementation]
  TSystemService = class(TInterfacedObject, ISystemService)
  private

    function Info(TZ: String):TStream;

  end;

implementation

uses Unit2, TZDB;

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



initialization
  RegisterServiceType(TSystemService);

end.
