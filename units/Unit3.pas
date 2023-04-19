unit Unit3;

interface

uses
  System.SysUtils,
  System.Classes,
  System.NetEncoding,
  System.Math,
  System.DateUtils,

  XData.Server.Module,
  XData.Service.Common,
  XData.Sys.Exceptions,

  HashObj,
  MiscObj,

  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  FireDAC.Comp.Client,
  FireDAC.Stan.StorageBin,
  FireDAC.Stan.StorageJSON,
  FireDAC.Stan.StorageXML,
  FireDAC.Comp.BatchMove,
  FireDAC.Comp.BatchMove.Dataset,
  FireDAC.Comp.BatchMove.JSON,

  Data.DB,

  ActiveX; // For Co/UnInitailze when using XML StreamFormat;

type
  TDBSupport = class(TDataModule)
  private
    { Private declarations }
  public
    { Public declarations }
    procedure ConnectQuery(var conn: TFDConnection; var qry: TFDQuery; DatabaseName: String; DatabaseEngine: String);
    procedure DisconnectQuery(var conn: TFDConnection; var qry: TFDQuery);
    function HashThis(InputText: String):String;
    procedure Export(Format: String; QueryResult: TFDQuery; var OutputStream: TStream);
    function QueryToJSON(QueryResult: TFDQuery): String;
    function DecodeSession(s: String):TDateTime;

  end;

var
  DBSupport: TDBSupport;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

uses Unit1, Unit2;

function TDBSupport.HashThis(InputText: String):String;
var
  SHA2: TSHA2Hash;
begin
  SHA2 := TSHA2Hash.Create;
  SHA2.HashSizeBits:= 256;
  SHA2.OutputFormat:= hexa;
  SHA2.Unicode:= noUni;
  Result := LowerCase(SHA2.Hash(InputText));
  SHA2.Free;
end;

function TDBSupport.QueryToJSON(QueryResult: TFDQuery): String;
var
  bm: TFDBatchMove;
  bw: TFDBatchMoveJSONWriter;
  br: TFDBatchMoveDataSetReader;
  os: TMemoryStream;
begin
  os := TMemoryStream.Create;
  bm := TFDBatchMove.Create(nil);
  bw := TFDBatchMoveJSONWriter.Create(nil);
  br := TFDBatchMoveDataSetReader.Create(nil);
  try
    br.Dataset := QueryResult;
    bw.Stream := os;
    bm.Reader := br;
    bm.Writer := bw;
    bm.Execute;
    SetString(Result, PAnsiChar(os.Memory), os.Size );
  finally
    br.Free;
    bw.Free;
    bm.Free;
    os.Free;
  end;
end;

procedure TDBSupport.Export(Format: String; QueryResult: TFDQuery;  var OutputStream: TStream);
var
  ContentFormat: String;
  ContentType: String;

  L: TStringList;
  S: String;

  bm: TFDBatchMove;
  bw: TFDBatchMoveJSONWriter;
  br: TFDBatchMoveDataSetReader;

  ms: TMemoryStream;

  i: Integer;
begin
  ContentFormat := Uppercase(Trim(Format));
  ContentType := 'text/plain';


  if (ContentFormat = 'FIREDAC') then
  begin
    ContentType := 'application/json';
    OutputStream := TMemoryStream.Create;
    QueryResult.SaveToStream(OutputStream, sfJSON);
  end

  else if (ContentFormat = 'XML') then
  begin
    ContentType := 'application/xml';
    OutputStream := TMemoryStream.Create;
    CoInitialize(nil);
    try
      QueryResult.SaveToStream(OutputStream, sfXML);
    finally
      CoUninitialize;
    end;
  end

  else if (ContentFormat = 'BINARY') then
  begin
    ContentType := 'application/json';
    ms := TMemoryStream.Create;
    try
      QueryResult.SaveToStream(ms,sfBinary);
      ms.Position := 0;
      OutputStream := TMemoryStream.Create;
      TNetEncoding.Base64.Encode(ms, OutputStream);
    finally
      ms.Free;
    end;
  end

  else if (ContentFormat = 'PLAIN') then
  begin
    ContentType := 'text/plain';
    L := TStringList.Create;
    S := '';
    try
      QueryResult.First;
      while not QueryResult.Eof do
      begin
        S := '';
        for i := 0 to QueryResult.FieldCount - 1 do
        begin
          if (S > '') then S := S + '';
          S := S + '' + QueryResult.Fields[i].AsString + '';
        end;
        L.Add(S);
        QueryResult.Next;
      end;
    finally
      OutputStream := TMemoryStream.Create;
      L.SaveToStream(OutputStream);
      L.Free;
    end;
  end

  else if (ContentFormat = 'CSV') then
  begin
    ContentType := 'text/csv';
    L := TStringList.Create;
    S := '';
    for i := 0 to QueryResult.FieldCount - 1 do
    begin
      if (S > '') then S := S + ',';
      S := S + '"' +QueryResult.FieldDefs.Items[I].Name + '"';
    end;
    L.Add(S);
    try
      QueryResult.First;
      while not (QueryResult.EOF) do
      begin
        S := '';
        for i := 0 to QueryResult.FieldCount - 1 do
        begin
          if (S > '') then S := S + ',';
          S := S + '"' + QueryResult.Fields[I].AsString + '"';
        end;
        L.Add(S);
        QueryResult.Next;
      end;
    finally
      OutputStream := TMemoryStream.Create;
      L.SaveToStream(OutputStream);
      L.Free;
    end;
  end

  else // if ContentFormat = 'JSON' then
  begin
    ContentType := 'application/json';
    OutputStream := TMemoryStream.Create;
    bm := TFDBatchMove.Create(nil);
    bw := TFDBatchMoveJSONWriter.Create(nil);
    br := TFDBatchMoveDataSetReader.Create(nil);
    try
      br.Dataset := QueryResult;
      bw.Stream := OutputStream;
      bm.Reader := br;
      bm.Writer := bw;
      bm.Execute;
    finally
      br.Free;
      bw.Free;
      bm.Free;
    end;
  end;

  TXDataOperationContext.Current.Response.Headers.SetValue('content-type', ContentType);

end;

procedure TDBSupport.ConnectQuery(var conn: TFDConnection; var qry: TFDQuery; DatabaseName: String; DatabaseEngine: String);
begin
  try
    // Establish a new connection for each endpoint invocation (not ideal!)
    if DatabaseEngine = 'sqlite' then
    begin
      conn := TFDConnection.Create(nil);
      conn.Params.Clear;
      conn.Params.DriverID := 'SQLite';
      conn.Params.Database := DatabaseName;
      conn.Params.Add('DateTimeFormat=String');
      conn.Params.Add('Synchronous=Full');
      conn.Params.Add('LockingMode=Normal');
      conn.Params.Add('SharedCache=False');
      conn.Params.Add('UpdateOptions.LockWait=True');
      conn.Params.Add('BusyTimeout=10000');
      conn.Params.Add('SQLiteAdvanced=page_size=4096');
      // Extras
      conn.FormatOptions.StrsEmpty2Null := True;
      with conn.FormatOptions do
      begin
        StrsEmpty2Null := true;
        OwnMapRules := True;
        with MapRules.Add do begin
          SourceDataType := dtWideMemo;
          TargetDataType := dtWideString;
        end;
      end;
    end;

    conn.Open;

    // Create a query to do our work
    qry := TFDQuery.Create(nil);
    qry.Connection := conn;

  except on E: Exception do
    begin
      // If the above fails, not a good thing, but at least try and make a note as to why
      Mainform.mmInfo.Lines.Add('[ '+E.ClassName+' ] '+E.Message);
    end;
  end;
end;

function TDBSupport.DecodeSession(s: String): TDateTime;
var
  i: Double;
  ex: INteger;

const
  c: TArray<String> = ['B','b','C','c','D','d','F','f','G','g','H','h','J','j','K','k','L','M','m','N','n','P','p','Q','q','R','r','S','s','T','t','V','W','w','X','x','Z','z','0','1','2','3','4','5','6','7','8','9'];

  function findc(s: String): Integer;
  var
    j: integer;
  begin
    Result := -1;
    j := 0;
    while j < length(c) do
    begin
      if c[j] = s then result := j;
      j := j + 1;
    end;
  end;

begin
  // https://github.com/marko-36/base29-shortener

  // This decodes a custom Base-48 encoded string back into an integer.
  // This is used to pass the action log session id which is just the
  // app start time in UTC as a unix datetime format.  Why?  So we
  // get a nice short session id that we can use without being as
  // burdensome as something like a GUID.

  // JavaScript:
  //      i = 0;
  //      for (var ex=0; ex<s.length; ++ex){
  //        i += c.indexOf(s.substring(ex,ex+1)) * Math.pow(c.length,s.length-1-ex);
  //      }
  //      return i;

  i := 0;
  ex := 0;
  while  ex < Length(s) do
  begin
    i := i + findc(Copy(s,ex+1,1)) * Power(Length(c), Length(s) - 1 - ex);
    ex := ex + 1;
  end;

  Result := UnixToDateTime(Trunc(i));

end;

procedure TDBSupport.DisconnectQuery(var conn: TFDConnection; var qry: TFDQuery);
begin
  try
    // Cleanup query that was created
    qry.Close;
    qry.Free;

    // Cleanup connection that was created
    conn.close;
    conn.Free;

  except on E: Exception do
    begin
      // If the above fails, not a good thing, but at least try and make a note as to why
      MainForm.mmInfo.Lines.Add('[ '+E.ClassName+' ] '+E.Message);
    end;
  end;
end;


end.
