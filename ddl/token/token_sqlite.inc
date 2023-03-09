// [table] token
//
// We don't really have any reason to create sample data here.

TableName := 'token';

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
                '  token_hash                 text        NOT NULL, '+
                '  valid_after                text        NOT NULL, '+
                '  valid_until                text        NOT NULL, '+
                '  person_id                  integer     NOT NULL, '+
                '  application                text        NOT NULL, '+
                '  version                    text        NOT NULL, '+
                '  ip_address                 text        NOT NULL, '+
                '  CONSTRAINT constraint_name PRIMARY KEY (token_hash) '+
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

