unit Unit2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Unit1, System.IOUtils, System.DateUtils, IdStack, IdGlobal, psAPI, WinAPi.ShellAPI,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteDef, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Phys.SQLite,
  Vcl.ExtCtrls;

type
  TMainForm = class(TForm)
    mmInfo: TMemo;
    btStart: TButton;
    btStop: TButton;
    btSwagger: TButton;
    DBConn: TFDConnection;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    Query1: TFDQuery;
    tmrStart: TTimer;
    procedure btStartClick(ASender: TObject);
    procedure btStopClick(ASender: TObject);
    procedure FormCreate(ASender: TObject);
    function GetAppName: String;
    function GetAppRelease: TDateTime;
    function GetAppReleaseUTC: TDateTime;
    function GetAppVersion: String;
    procedure GetAppParameters(List: TStringList);
    function GetAppFileName: String;
    function GetAppFileSize: Int64;
    function GetAppTimeZone: String;
    function GetAppTimeZoneOffset: Integer;
    procedure GetIPAddresses(List: TStringList);
    function GetMemoryUsage: NativeUInt;
    procedure btSwaggerClick(Sender: TObject);
    procedure tmrStartTimer(Sender: TObject);
  public
    AppName: String;
    AppVersion: String;
    AppRelease: TDateTime;
    AppReleaseUTC: TDateTime;
    AppParameters: TStringList;
    AppFileSize: Int64;
    AppFileName: String;
    AppTimeZone: String;
    AppTimeZoneOffset: Integer;
    IPAddresses: TStringList;

    DatabaseName: String;
    DatabaseAlias: String;
    DatabaseEngine: String;
    DatabaseUsername: String;
    DatabasePassword: String;
    DatabaseConfig: String;

  strict private
    procedure UpdateGUI;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

resourcestring
  SServerStopped = 'Server stopped';
  SServerStartedAt = 'Server started at ';

{ TMainForm }

procedure TMainForm.btStartClick(ASender: TObject);
begin
  ServerContainer.SparkleHttpSysDispatcher.Start;
  UpdateGUI;
end;

procedure TMainForm.btStopClick(ASender: TObject);
begin
  ServerContainer.SparkleHttpSysDispatcher.Stop;
  UpdateGUI;
end;

procedure TMainForm.btSwaggerClick(Sender: TObject);
var
  url: String;
const
  cHttp = 'http://+';
  cHttpLocalhost = 'http://localhost';
begin
  url := StringReplace(
      ServerContainer.XDataServer.BaseUrl,
      cHttp, cHttpLocalhost, [rfIgnoreCase])+'/swaggerui';
  ShellExecute(0, 'open', PChar(url), nil, nil, SW_SHOWNORMAL);
end;

procedure TMainForm.FormCreate(ASender: TObject);
begin

  // Get System Values
  AppName := GetAppName;
  AppVersion := GetAppVersion;
  AppRelease := GetAppRelease;
  AppReleaseUTC := GetAppReleaseUTC;
  AppFileName := GetAppFileName;
  AppFileSize := GetAppFileSize;
  AppTimeZone := GetAppTimeZone;
  AppTimeZoneOffset := GetAppTimeZoneOffset;

  // This is a list
  AppParameters := TStringList.Create;
  AppParameters.QuoteChar := ' ';
  GetAppParameters(AppParameters);

  // This is also a list
  IPAddresses := TStringList.Create;
  IPAddresses.QuoteChar := ' ';
  GetIPAddresses(IPAddresses);

  tmrStart.Enabled := True;
end;

function TMainForm.GetAppFileName: String;
begin
  Result := ParamStr(0);
end;

function TMainForm.GetAppFileSize: Int64;
var
  SearchRec: TSearchRec;
begin
  Result := -1;
  if FindFirst(ParamStr(0), faAnyFile, SearchRec) = 0
  then Result := SearchRec.Size;
  FindClose(SearchRec);
end;

function TMainForm.GetAppName: String;
begin
  Result := MainForm.Caption;
end;

procedure TMainForm.GetAppParameters(List: TStringList);
var
  i: Integer;
begin
  i := 1;
  while i <= ParamCount do
  begin
    List.Add('"'+ParamStr(i)+'"');
    i := i + 1;
  end;
end;

function TMainForm.GetAppRelease: TDateTime;
begin
  Result := System.IOUtils.TFile.GetLastWriteTime(ParamStr(0));
end;

function TMainForm.GetAppReleaseUTC: TDateTime;
begin
  Result := System.IOUtils.TFile.GetLastWriteTimeUTC(ParamStr(0));
end;

function TMainForm.GetAppTimeZone: String;
var
  ZoneInfo: TTimeZoneInformation;
begin
  GetTimeZoneInformation(ZoneInfo);
  Result := ZoneInfo.StandardName;
end;

function TMainForm.GetAppTimeZoneOffset: Integer;
var
  ZoneInfo: TTimeZoneInformation;
begin
  GetTimeZoneInformation(ZoneInfo);
  Result := ZoneInfo.Bias;
end;

// https://stackoverflow.com/questions/1717844/how-to-determine-delphi-application-version
function TMainForm.GetAppVersion: String;
const
  c_StringInfo = 'StringFileInfo\040904E4\FileVersion';
var
  n, Len : cardinal;
  Buf, Value : PChar;
  exeName:String;
begin
  exeName := ParamStr(0);
  Result := '';
  n := GetFileVersionInfoSize(PChar(exeName),n);
  if n > 0 then begin
    Buf := AllocMem(n);
    try
      GetFileVersionInfo(PChar(exeName),0,n,Buf);
      if VerQueryValue(Buf,PChar(c_StringInfo),Pointer(Value),Len) then begin
        Result := Trim(Value);
      end;
    finally
      FreeMem(Buf,n);
    end;
  end;
end;

// https://stackoverflow.com/questions/576538/delphi-how-to-get-all-local-ips
procedure TMainForm.GetIPAddresses(List: TStringList);
var
  i: Integer;
  IPList: TIdStackLocalAddressList;
  IPAddr: TIdStackLocalAddress;
begin
  TIdStack.IncUsage;
  List.Clear;
  IPList := TIdStackLocalAddressList.Create;
  try
    GStack.GetLocalAddressList(IPList);
    for i := 0 to IPList.Count-1 do
    begin
      IPAddr := IPList[I];
      case IPAddr.IPVersion of
        Id_IPv4: begin
                   List.Add('IPV4: '+IPAddr.IPAddress);
                 end;
        Id_IPv6: begin
                   List.Add('IPV6: '+IPAddr.IPAddress);
                 end;
        end;
    end;
  finally
    IPList.Free;
    TIdStack.DecUsage;
  end;
  List.Sort;
  i := 0;
  while i < List.Count do
  begin
    List[i] := '"'+List[i]+'"';
    i := i +1;
  end;
end;

// https://stackoverflow.com/questions/437683/how-to-get-the-memory-used-by-a-delphi-program
function TMainForm.GetMemoryUsage: NativeUInt;
var
  MemCounters: TProcessMemoryCounters;
begin
  Result := 0;
  MemCounters.cb := SizeOf(MemCounters);
  if GetProcessMemoryInfo(GetCurrentProcess, @MemCounters, SizeOf(MemCounters))
  then Result := MemCounters.WorkingSetSize
  else mmInfo.Lines.add('ERROR: WorkingSetSize not available');
end;


procedure TMainForm.tmrStartTimer(Sender: TObject);
var
  i: Integer;
begin

  tmrStart.Enabled := False;

  // FDConnection component dropped on form - DBConn
  // FDPhysSQLiteDriverLink component droppoed on form
  // FDQuery component dropped on form - Query1
  // DatabaseName is a Form Variable
  // DatabaseEngine is a Form Variable
  // DatabaseUsername is a Form Variable
  // DatabasePassword is a Form Variable

  mmInfo.Lines.Add('Initializing Database...');

  DatabaseEngine := 'sqlite';
  DatabaseName := 'DemoData.sqlite';
  DatabaseAlias := 'DemoData';
  DatabaseUsername := 'dbuser';
  DatabasePassword := 'dbpass';
  DatabaseConfig := '';

  i := 1;
  while i <= ParamCount do
  begin
    if Pos('DBNAME=',Uppercase(ParamStr(i))) = 1
    then DatabaseName := Copy(ParamStr(i),8,length(ParamStr(i)));

    if Pos('DBALIAS=',Uppercase(ParamStr(i))) = 1
    then DatabaseAlias := Copy(ParamStr(i),8,length(ParamStr(i)));

    if Pos('DBENGINE=',Uppercase(ParamStr(i))) = 1
    then DatabaseEngine := Lowercase(Copy(ParamStr(i),10,length(ParamStr(i))));

    if Pos('DBUSER=',Uppercase(ParamStr(i))) = 1
    then DatabaseUsername := Copy(ParamStr(i),8,length(ParamStr(i)));

    if Pos('DBPASS=',Uppercase(ParamStr(i))) = 1
    then DatabasePassword := Copy(ParamStr(i),8,length(ParamStr(i)));

    if Pos('DBCONFIG=',Uppercase(ParamStr(i))) = 1
    then DatabaseConfig := Copy(ParamStr(i),8,length(ParamStr(i)));

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
  mmInfo.Lines.Add('...['+DatabaseEngine+'] '+DatabaseName);

  // Create and populate tables
  {$Include ddl\person\person.inc}
  {$Include ddl\role\role.inc}
  {$Include ddl\person_role\person_role.inc}
  {$Include ddl\api_key\api_key.inc}
  {$Include ddl\contact\contact.inc}
  {$Include ddl\endpoint_history\endpoint_history.inc}
  {$Include ddl\ip_allow\ip_allow.inc}
  {$Include ddl\ip_block\ip_block.inc}
  {$Include ddl\list\list.inc}
  {$Include ddl\login_fail\login_fail.inc}
  {$Include ddl\login_history\login_history.inc}
  {$Include ddl\token\token.inc}

  mmInfo.Lines.Add('Done.');
  mmInfo.Lines.Add('');

  UpdateGUI;

  // Display System Values
  mmInfo.Lines.Add('');
  mmInfo.Lines.Add('App Name: '+AppName);
  mmInfo.Lines.Add('...Version: '+AppVersion);
  mmInfo.Lines.Add('...Release: '+FormatDateTime('yyyy-mmm-dd (ddd) hh:nn:ss', AppRelease));
  mmInfo.Lines.Add('...Release UTC: '+FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', AppReleaseUTC));
  mmInfo.Lines.Add('...Memory Usage: '+Format('%.1n',[GetMemoryUsage / 1024 / 1024])+' MB');
  mmInfo.Lines.Add('...File Name: '+AppFileName);
  mmInfo.Lines.Add('...File Size: '+Format('%.1n',[AppFileSize / 1024 / 1024])+' MB');
  mmInfo.Lines.Add('...TimeZone: '+AppTimeZone);
  mmInfo.Lines.Add('...TimeZone Offset: '+IntToStr(AppTimeZoneOffset)+'m');
  mmInfo.Lines.Add('...Parameters:');
  mmInfo.Lines.AddStrings(AppParameters);
  mmInfo.Lines.Add('...IP Addresses:');
  mmInfo.Lines.AddStrings(IPAddresses);
  mmInfo.Lines.Add('Ready.');
  mmInfo.Lines.Add('');

end;

procedure TMainForm.UpdateGUI;
const
  cHttp = 'http://+';
  cHttpLocalhost = 'http://localhost';
begin
  btStart.Enabled := not ServerContainer.SparkleHttpSysDispatcher.Active;
  btStop.Enabled := not btStart.Enabled;
  if ServerContainer.SparkleHttpSysDispatcher.Active then
    mmInfo.Lines.Add(SServerStartedAt + StringReplace(
      ServerContainer.XDataServer.BaseUrl,
      cHttp, cHttpLocalhost, [rfIgnoreCase]))
  else
    mmInfo.Lines.Add(SServerStopped);
end;

end.
