// [table] ip_block

if (DatabaseEngine = 'sqlite') then
begin

  with Query1 do
  begin

    SQL.Clear;
    SQL.Add('create table if not exists ip_block ('+
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

    SQL.Clear;
    SQL.Add('select count(*) records from ip_block;');
    Open;

    if FieldByName('records').AsInteger = 0 then
    begin
      SQL.Clear;

      // Just as an example
      SQL.Add('insert into ip_block values( "0.0.0.0", Datetime("now"), 0, Datetime("now"), Datetime("now", "+100 years"), "Not a valid IP address - Permanent Ban" );');

      ExecSQL;
    end;
  end;
end;

