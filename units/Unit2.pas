unit Unit2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,System.Types,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Unit1, System.IOUtils, System.DateUtils, IdStack, IdGlobal, psAPI, WinAPi.ShellAPI,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteDef, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Phys.SQLite,
  Vcl.ExtCtrls, System.JSON, System.StrUtils,IdGlobalProtocols, System.Generics.Collections;

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
    tmrInit: TTimer;
    btRedoc: TButton;
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
    procedure FormShow(Sender: TObject);
    procedure tmrInitTimer(Sender: TObject);
    procedure btRedocClick(Sender: TObject);
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
    AppConfigFile: String;
    AppConfiguration: TJSONObject;
    ChatModels: TStringList;
    AppCacheFolder: String;

    AppIconsFolder: String;
    AppIcons: TJSONArray;
    AppIconSets: String;

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

{ TMainForm }

procedure TMainForm.btRedocClick(Sender: TObject);
var
  url: String;
const
  cHttp = '://+';
  cHttpLocalhost = '://localhost';
begin
  url := StringReplace(
      ServerContainer.XDataServer.BaseUrl,
      cHttp, cHttpLocalhost, [rfIgnoreCase])+'/redoc';
  ShellExecute(0, 'open', PChar(url), nil, nil, SW_SHOWNORMAL);
end;

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
  cHttp = '://+';
  cHttpLocalhost = '://localhost';
begin
  url := StringReplace(
      ServerContainer.XDataServer.BaseUrl,
      cHttp, cHttpLocalhost, [rfIgnoreCase])+'/swaggerui';
  ShellExecute(0, 'open', PChar(url), nil, nil, SW_SHOWNORMAL);
end;

procedure TMainForm.FormCreate(ASender: TObject);
begin
  tmrInit.Enabled := True;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  if MainForm.Tag = 0 then
  begin
    MainForm.Tag := 1;
    MainForm.WindowState := wsMaximized;
    MainForm.WindowState := wsMinimized;
  end;
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


procedure TMainForm.tmrInitTimer(Sender: TObject);
var
  i: Integer;
  ConfigFile: TStringList;
begin
  tmrInit.Enabled := False;

  // Let's use these internally for consistency
  FormatSettings.DateSeparator   := '-';
  FormatSettings.ShortDateFormat := 'yyyy-mm-dd';
  FormatSettings.TimeSeparator   := ':';
  FormatSettings.ShortTimeFormat := 'hh:nn:ss';

  // Get System Values
  AppName := GetAppName;
  AppVersion := GetAppVersion;
  AppRelease := GetAppRelease;
  AppReleaseUTC := GetAppReleaseUTC;
  AppFileName := GetAppFileName;
  AppFileSize := GetAppFileSize;
  AppTimeZone := GetAppTimeZone;
  AppTimeZoneOffset := GetAppTimeZoneOffset;

  // List of App Parameters
  AppParameters := TStringList.Create;
  AppParameters.QuoteChar := ' ';
  GetAppParameters(AppParameters);

  // List of IP Addresses
  IPAddresses := TStringList.Create;
  IPAddresses.QuoteChar := ' ';
  GetIPAddresses(IPAddresses);

  // Load JSON Configuration
  mmINfo.Lines.Add('Loading Configuration ...');
  AppConfigFile := StringReplace(ExtractFileName(ParamStr(0)),'exe','json',[]);
  i := 0;
  while i < AppParameters.Count do
  begin
    if Pos('"CONFIG=',UpperCase(AppParameters[i])) = 1
    then AppConfigFile  := Copy(AppParameters[i],9,length(AppParameters[i])-9);
    i := i + 1;
  end;
  ConfigFile := TStringList.Create;
  if FileExists(AppConfigFile) then
  begin
    try
      ConfigFile.LoadFromFile(AppConfigFile);
      mmInfo.Lines.Add('...Configuration File Loaded: '+AppConfigFile);
      AppConfiguration := TJSONObject.ParseJSONValue(ConfigFile.Text) as TJSONObject;
    except on E: Exception do
      begin
        mmInfo.Lines.Add('...Configuration File Error: '+AppConfigFile);
        mmInfo.Lines.Add('...['+E.ClassName+'] '+E.Message);
      end;
    end;
  end
  else // File doesn't exist
  begin
    mmInfo.Lines.Add('...Configuration File Not Found: '+AppConfigFile);
  end;
  ConfigFile.Free;
  Application.ProcessMessages;

  if Appconfiguration = nil then
  begin
    // Create an empty AppConfiguration
    mmInfo.Lines.Add('...Using Default Configuration');
    AppConfiguration := TJSONObject.Create;
    AppConfiguration.AddPair('BaseURL','http://+:12345/tms/xdata');
    AppConfiguration.AddPair('ServerName','TMS XData Template: Demo Data');
  end;
  mmInfo.Lines.Add('Done.');
  mmInfo.Lines.Add('');
  Application.ProcessMessages;

  if AppConfiguration.getValue('BaseURL') <> nil
  then ServerContainer.XDataServer.BaseURL := (AppConfiguration.getValue('BaseURL') as TJSONString).Value;

  if AppConfiguration.getValue('ServerName') <> nil
  then Caption := (AppConfiguration.getValue('ServerName') as TJSONString).Value;

  tmrStart.Enabled := True;

end;

procedure TMainForm.tmrStartTimer(Sender: TObject);
var
  i: Integer;
  ImageFile: TStringList;
  TableName: String;
  CacheFolderDirs: String;
  CacheFolderFiles: String;
  CacheFolderSize: Double;
  CacheFolderList: TStringDynArray;
  IconFiles: TStringDynArray;
  IconFile: TStringList;
  IconJSON: TJSONObject;
  IconSets: TJSONArray;
  IconWidth: Integer;
  IconHeight: Integer;
  IconCount: Integer;
  IconTotal: Integer;
begin

  tmrStart.Enabled := False;

  // This is (potentially) used when populating the photo table
  ImageFile := TStringList.Create;

  // FDConnection component dropped on form - DBConn
  // FDQuery component dropped on form - Query1
  //
  // FDPhysSQLiteDriverLink component droppoed on form
  // support for other databases should do the same
  //
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
    with DBConn.FormatOptions do
    begin
      OwnMapRules := True;
      StrsEmpty2Null := True;
      with MapRules.Add do begin
        SourceDataType := dtWideMemo;
        TargetDataType := dtWideString;
      end;
    end;
  end;

  DBConn.Open;
  Query1.Connection := DBConn;
  mmInfo.Lines.Add('...['+DatabaseEngine+'] '+DatabaseName);

  Application.ProcessMessages;

  // Create and populate tables
  {$Include ddl\person\person.inc}
  Application.ProcessMessages;
  {$Include ddl\role\role.inc}
  Application.ProcessMessages;
  {$Include ddl\person_role\person_role.inc}
  Application.ProcessMessages;
  {$Include ddl\api_key\api_key.inc}
  Application.ProcessMessages;
  {$Include ddl\contact\contact.inc}
  Application.ProcessMessages;
  {$Include ddl\endpoint_history\endpoint_history.inc}
  Application.ProcessMessages;
  {$Include ddl\ip_allow\ip_allow.inc}
  Application.ProcessMessages;
  {$Include ddl\ip_block\ip_block.inc}
  Application.ProcessMessages;
  {$Include ddl\list\list.inc}
  Application.ProcessMessages;
  {$Include ddl\login_fail\login_fail.inc}
  Application.ProcessMessages;
  {$Include ddl\login_history\login_history.inc}
  Application.ProcessMessages;
  {$Include ddl\token\token.inc}
  Application.ProcessMessages;
  {$Include ddl\photo\photo.inc}
  Application.ProcessMessages;
  {$Include ddl\action_history\action_history.inc}
  Application.ProcessMessages;
  {$Include ddl\chatai_history\chatai_history.inc}
  Application.ProcessMessages;
  {$Include ddl\imageai_history\imageai_history.inc}
  Application.ProcessMessages;

  mmInfo.Lines.Add('Done.');
  mmInfo.Lines.Add('');

  // Cache Folder
  if (AppConfiguration.GetValue('Cache Folder') <> nil)
  then AppCacheFolder := (AppConfiguration.GetValue('Cache Folder') as TJSONString).Value
  else AppCacheFolder := GetCurrentDir+'/cache';
  if RightStr(AppCacheFolder,1) <> '/'
  then AppCacheFolder := AppCacheFolder + '/';

  if not(ForceDirectories(AppCacheFolder))
  then mmInfo.Lines.Add('ERROR Initializing Cache Folder: '+AppCacheFolder);
  if not(ForceDirectories(AppCacheFolder+'images'))
  then mmInfo.Lines.Add('ERROR Initializing Cache Folder: '+AppCacheFolder+'images');
  if not(ForceDirectories(AppCacheFolder+'images/ai'))
  then mmInfo.Lines.Add('ERROR Initializing Cache Folder: '+AppCacheFolder+'images/ai');
  if not(ForceDirectories(AppCacheFolder+'images/people'))
  then mmInfo.Lines.Add('ERROR Initializing Cache Folder: '+AppCacheFolder+'images/people');

  CacheFolderDirs  := FloatToStrF(Length(TDirectory.GetDirectories(AppCacheFolder,'*',TsearchOption.soAllDirectories)),ffNumber,8,0);
  CacheFolderList := TDirectory.GetFiles(AppCacheFolder,'*.*',TsearchOption.soAllDirectories);
  CacheFolderFiles := FloatToStrF(Length(CacheFolderList),ffNumber,8,0);
  CacheFolderSize := 0;
  for i := 0 to Length(CacheFolderList)-1 do
    CacheFolderSize := CacheFolderSize + (FileSizeByName(CacheFolderList[i]) / 1024 / 1024);

  // Display System Values
  mmInfo.Lines.Add('App Name: '+AppName);
  mmInfo.Lines.Add('...Version: '+AppVersion);
  mmInfo.Lines.Add('...Release: '+FormatDateTime('yyyy-mmm-dd (ddd) hh:nn:ss', AppRelease));
  mmInfo.Lines.Add('...Release UTC: '+FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', AppReleaseUTC));
  mmInfo.Lines.Add('...Server Time: '+FormatDateTime('yyyy-mmm-dd (ddd) hh:nn:ss', Now));
  mmInfo.Lines.Add('...TimeZone: '+AppTimeZone);
  mmInfo.Lines.Add('...TimeZone Offset: '+IntToStr(AppTimeZoneOffset)+'m');
  mmInfo.Lines.Add('...Base URL: '+ServerContainer.XDataServer.BaseURL);
  mmInfo.Lines.Add('...File Name: '+AppFileName);
  mmInfo.Lines.Add('...File Size: '+Format('%.1n',[AppFileSize / 1024 / 1024])+' MB');
  mmInfo.Lines.Add('...Cache Folder: '+AppCacheFolder);
  mmInfo.Lines.Add('...Cache Statistics: '+CacheFolderDirs+' Folders, '+CacheFolderFiles+' Files, '+FloatToStrF(CacheFolderSize,ffNumber,8,1)+' MB');
  mmInfo.Lines.Add('...Memory Usage: '+Format('%.1n',[GetMemoryUsage / 1024 / 1024])+' MB');

  mmInfo.Lines.Add('...Parameters:');
  i := 0;
  while i < AppParameters.Count do
  begin
    mmInfo.Lines.Add('        '+StringReplace(AppParameters[i],'"','',[rfReplaceAll]));
    i := i + 1;
  end;

  mmInfo.Lines.Add('...IP Addresses:');
  i := 0;
  while i < IPAddresses.Count do
  begin
    mmInfo.Lines.Add('        '+StringReplace(IPAddresses[i],'"','',[rfReplaceAll]));
    i := i + 1;
  end;


  // Are chat services avialable?
  if (AppConfiguration.GetValue('Chat Interface') as TJSONArray) = nil
  then mmInfo.Lines.Add('...Chat: UNAVAILABLE')
  else
  begin
    mmInfo.Lines.Add('...Chat:');
    i := 0;
    while i < (AppConfiguration.GetValue('Chat Interface') as TJSONArray).Count do
    begin;
      mmInfo.Lines.Add('        '+(((AppConfiguration.GetValue('Chat Interface') as TJSONArray).items[i] as TJSONObject).getValue('Name') as TJSONString).Value);
      i := i + 1;
    end;
  end;


  // Load up Icon Sets
  if (AppConfiguration.GetValue('Icons') <> nil)
  then AppIconsFolder := (AppConfiguration.GetValue('Icons') as TJSONString).Value
  else AppIconsFolder := GetCurrentDir+'/icon-sets';
  if RightStr(AppIconsFolder,1) <> '/'
  then AppIconsFolder := AppIconsFolder + '/';
  ForceDirectories(AppIconsFolder);
  IconFiles := TDirectory.GetFiles(AppIconsFolder,'*.json',TsearchOption.soAllDirectories);

  AppIcons := TJSONArray.Create;
  IconSets := TJSONArray.Create;
  IconTotal := 0;

  if length(IconFiles) = 0 then
  begin
    mmInfo.Lines.Add('...No Icon Sets Loaded: None Found.');
  end
  else
  begin
    mmInfo.Lines.Add('...Loading '+IntToStr(Length(IconFiles))+' Icon Sets:');
    IconFile := TStringList.Create;

    for i := 0 to Length(IconFiles)-1 do
    begin
      // Load JSON File
      IconFile.LoadFromFile(IconFiles[i], TEncoding.UTF8);
      IconJSON := TJSONObject.ParseJSONValue(IconFile.Text) as TJSONObject;
      AppIcons.Add(IconJSON);

      // Get Icon Count information
      IconCount := (IconJSON.GetValue('icons') as TJSONObject).Count;
      IconTotal := IconTotal + IconCount;

      // Log what we're doing
      mmInfo.Lines.Add('        ['+TPath.GetFileName(IconFiles[i])+'] '+
        ((IconJSON.GetValue('info') as TJSONObject).GetValue('name') as TJSONString).Value+' - '+
        IntToStr(IconCount)+' Icons');

      // Sort out the default width and height.  This is either from the width and height properties
      // found in the root of the JSON object, or in the info element, or perhaps not at all in the
      // the case of the width property, in which case we'll assume it is the same as the height.
      // We're doing this now as we're not passing back this information to the client, just the
      // name, license, and icons, so the client will need this to properly generate the SVG data.
      IconHeight := 0;
      IconWidth := 0;
      if IconJSON.GetValue('height') <> nil
      then IconHeight := (IconJSON.GetValue('height') as TJSONNumber).AsInt
      else if (IconJSON.GetValue('info') as TJSONObject).GetValue('height') <> nil
           then IconHeight := ((IconJSON.GetValue('info') as TJSONObject).GetValue('height') as TJSONNumber).AsInt;
      if IconJSON.GetValue('width') <> nil
      then IconWidth := (IconJSON.GetValue('width') as TJSONNumber).AsInt
      else if (IconJSON.GetValue('info') as TJSONObject).GetValue('width') <> nil
           then IconWidth := ((IconJSON.GetValue('info') as TJSONObject).GetValue('width') as TJSONNumber).AsInt;
      if IconWidth = 0 then IconWidth := IconHeight;

      // Here we're building the JSON that we'll pass to the client telling them what icon sets are
      // available, along with the other data they will need that is at the icon-set level
      IconSets.add(TJSONObject.ParseJSONValue('{'+
        '"name":"'+((IconJSON.GetValue('info') as TJSONObject).GetValue('name') as TJSONString).Value+'",'+
        '"license":"'+(((IconJSON.GetValue('info') as TJSONObject).GetValue('license') as TJSONObject).GetValue('title') as TJSONString).Value+'",'+
        '"width":'+IntToStr(IconWidth)+','+
        '"height":'+IntToStr(IconHeight)+','+
        '"count":'+IntToStr(IconCount)+','+
        '"library":'+IntToStr(i)+
        '}') as TJSONObject);

      Application.ProcessMessages;
    end;
    IconFile.Free;
  end;
  mmInfo.Lines.Add('        Icons Loaded: '+FloatToStrF(IconTotal,ffNumber,10,0));

  // We don't need to do anything else with this, so we'll store it as a string and
  // then return just that when asked for this ata.
  AppIconSets := IconSets.ToString;


  mmInfo.Lines.Add('...Memory Usage: '+Format('%.1n',[GetMemoryUsage / 1024 / 1024])+' MB');
  mmInfo.Lines.Add('Done.');
  mmInfo.Lines.Add('');

  // Start Server
  ServerContainer.SparkleHttpSysDispatcher.Active := True;
  UpdateGUI;

  // Cleanup
  ImageFile.Free;
end;

procedure TMainForm.UpdateGUI;
const
  cHttp = '://+';
  cHttpLocalhost = '://localhost';
begin
  btStart.Enabled := not ServerContainer.SparkleHttpSysDispatcher.Active;
  btStop.Enabled := not btStart.Enabled;
  if ServerContainer.SparkleHttpSysDispatcher.Active then
  begin
    mmInfo.Lines.Add('XData Server started at '+StringReplace( ServerContainer.XDataServer.BaseUrl, cHttp, cHttpLocalhost, [rfIgnoreCase]));
    mmInfo.Lines.Add('SwaggerUI started at '+StringReplace( ServerContainer.XDataServer.BaseUrl, cHttp, cHttpLocalhost, [rfIgnoreCase])+'/swaggerui');
  end
  else
  begin
    mmInfo.Lines.Add('XData Server stopped');
  end;
end;

end.
