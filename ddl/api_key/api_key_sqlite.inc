// [table] api_key

TableName := 'api_key';

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
                '  api_key                    text        NOT NULL, '+
                '  last_modified              text        NOT NULL, '+
                '  last_modifier              integer     NOT NULL, '+
                '  valid_after                text        NOT NULL, '+
                '  valid_until                text        NOT NULL, '+
                '  application                text        NOT NULL, '+
                '  CONSTRAINT constraint_name PRIMARY KEY (api_key) '+
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

      // Default API Keys for testing - set to expire after three months
      SQL.Add('insert into '+TableName+' values( "testing", Datetime("now"), 0, Datetime("now"), Datetime("now", "+3 months"), "Testing XData Template Demo Data" );');
      SQL.Add('insert into '+TableName+' values( "{39A411D0-FB62-4F95-8F34-E63839D6E98E}", Datetime("now"), 0, Datetime("now"), Datetime("now", "+3 months"), "TMS WEB Core Template Demo" );');

      ExecSQL;
    end;
  end;
end;

