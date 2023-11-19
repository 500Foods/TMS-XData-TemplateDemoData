// [table] action_history
//
// We don't really have any reason to create sample data here.

TableName := 'action_history';

if (DatabaseEngine = 'sqlite') then
begin

  with Query1 do
  begin

    // Check if the table exists
    SQL.Clear;
    SQL.Add('select count(*) records from '+TableName+';');
    try
      Open;
      LogEvent('...'+TableName+' ('+IntToStr(FieldByName('records').AsInteger)+' records)');

    except on E:Exception do
      begin
        LogEvent('...'+TableName+' (CREATE)');
        SQL.Clear;
        SQL.Add('create table if not exists '+TableName+' ( '+
                '  person_id                  integer     NOT NULL, '+
                '  ip_address                 text        NOT NULL, '+
                '  application                text        NOT NULL, '+
                '  version                    text        NOT NULL, '+
                '  session_id                 text        NOT NULL, '+
                '  session_start              text        NOT NULL, '+
                '  session_recorded           text        NOT NULL, '+
                '  actions                    text        NOT NULL '+
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
//      LogEvent('...'+TableName+' (POPULATE)');
//      SQL.Clear;
//    end;

  end;
end;

