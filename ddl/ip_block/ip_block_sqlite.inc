// [table] ip_block

TableName := 'ip_block';

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
                '  ip_address                 text        NOT NULL, '+
                '  last_modified              text        NOT NULL, '+
                '  last_modifier              integer     NOT NULL, '+
                '  valid_after                text        NOT NULL, '+
                '  valid_until                text        NOT NULL, '+
                '  justification              text        NOT NULL, '+
                '  CONSTRAINT constraint_name PRIMARY KEY (ip_address) '+
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
    if (FieldByName('records').AsInteger = 0) then
    begin
      LogEvent('...'+TableName+' (POPULATE)');
      SQL.Clear;

      // Just as an example
      SQL.Add('insert into '+TableName+' values( "0.0.0.0", Datetime("now"), 0, Datetime("now"), Datetime("now", "+100 years"), "Not a valid IP address - Permanent Ban" );');

      ExecSQL;
    end;
  end;
end;

