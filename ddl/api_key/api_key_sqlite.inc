// [table] api_key

if (DatabaseEngine = 'sqlite') then
begin

  with FDQuery1 do
  begin

    SQL.Clear;
    SQL.Add('create table if not exists api_key ('+
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

    SQL.Clear;
    SQL.Add('select count(*) records from api_key;');
    Open;

    if FieldByName('records').AsInteger = 0 then
    begin
      SQL.Clear;

      // Default API Key for testing: "testing"
      SQL.Add('insert into api_key values( "testing", current_timestamp, 0, current_timestamp, "2100-01-01", "Testing XData Template Demo Data" );');
      SQL.Add('insert into api_key values( "{39A411D0-FB62-4F95-8F34-E63839D6E98E}", current_timestamp, 0, current_timestamp, "2100-01-01", "TMS WEB Core Template Demo" );');

      ExecSQL;
    end;
  end;
end;

