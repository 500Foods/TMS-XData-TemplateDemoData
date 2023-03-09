// [table] endpoint_history
//
// We don't really have any reason to create sample data here.

TableName := 'endpoint_history';

if (DatabaseEngine = 'sqlite') then
begin

  with Query1 do
  begin

    // Check if the table exists
    SQL.Clear;
    SQL.Add('select count(*) records from '+TableName+';');
    try
      Open;
      mmInfo.Lines.Add('...'+TableName+' ('+IntToStr(FieldByName('records').AsInteger)+' records)');

    except on E:Exception do
      begin
        mmInfo.Lines.Add('...'+TableName+' (CREATE)');
        SQL.Clear;
        SQL.Add('create table if not exists '+TableName+' ( '+
                '  person_id                  integer     NOT NULL, '+
                '  endpoint                   text        NOT NULL, '+
                '  accessed                   text        NOT NULL, '+
                '  execution_ms               integer     NOT NULL, '+
                '  ip_address                 text        NOT NULL, '+
                '  application                text        NOT NULL, '+
                '  version                    text        NOT NULL, '+
                '  database_name              text        NOT NULL, '+
                '  database_engine            text        NOT NULL, '+
                '  details                    text                  '+
            ');'
           );

        ExecSQL;

        // Try it again
        SQL.Clear;
        SQL.Add('select count(*) records from '+TableName+';');
        Open;
      end;
    end;

    // Populate empty table with sample data
//    if (FieldByName('records').AsInteger = 0) then
//    begin
//      mmInfo.Lines.Add('...'+TableName+' (POPULATE)');
//      SQL.Clear;
//    end;

  end;
end;

