unit Unit3;

interface

uses
  System.SysUtils,
  System.Classes,

  XData.Server.Module,
  XData.Service.Common,
  XData.Sys.Exceptions,

  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  FireDAC.Comp.Client,
  FireDAC.Comp.BatchMove,
  FireDAC.Comp.BatchMove.Dataset,
  FireDAC.Comp.BatchMove.JSON;

type
  TDBSupport = class(TDataModule)
  private
    { Private declarations }
  public
    { Public declarations }
    procedure ConnectQuery(var conn: TFDConnection; var qry: TFDQuery);
    procedure CleanupQuery(var conn: TFDConnection; var qry: TFDQuery);
  end;

var
  DBSupport: TDBSupport;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

uses Unit1, Unit2;

procedure TDBSupport.ConnectQuery(var conn: TFDConnection; var qry: TFDQuery);
begin
  try
    // Establish a new connection for each endpoint invocation (not ideal!)
    conn := TFDConnection.Create(nil);
    conn.Params.Clear;
    conn.Params.DriverID := 'SQLite';
    conn.Params.Database := ServerContainer.DatabaseName;
    conn.Params.Add('Synchronous=Full');
    conn.Params.Add('LockingMode=Normal');
    conn.Params.Add('SharedCache=False');
    conn.Params.Add('UpdateOptions.LockWait=True');
    conn.Params.Add('BusyTimeout=10000');
    conn.Params.Add('SQLiteAdvanced=page_size=4096');
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

procedure TDBSupport.CleanupQuery(var conn: TFDConnection; var qry: TFDQuery);
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
