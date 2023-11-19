// [table] login_fail
//
// We don't really have any reason to create sample data here.

TableName := 'login_fail';

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
                '  login_id                   text        NOT NULL, '+
                '  ip_address                 text        NOT NULL, '+
                '  attempted                  integer     NOT NULL, '+
                '  CONSTRAINT constraint_name PRIMARY KEY (login_id,ip_address,attempted) '+
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

