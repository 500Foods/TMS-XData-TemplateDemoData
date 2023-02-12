// [table] ip_allow

if (DatabaseEngine = 'sqlite') then
begin

  with Query1 do
  begin

    SQL.Clear;
    SQL.Add('create table if not exists ip_allow ('+
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
    SQL.Add('select count(*) records from ip_allow;');
    Open;

    if FieldByName('records').AsInteger = 0 then
    begin
      SQL.Clear;

      // Local IPs
      SQL.Add('insert into ip_allow values( "127.0.0.1", Datetime("now"), 0, Datetime("now"), Datetime("now","+100 years"), "Local development IP address - Always Allow" );');
      SQL.Add('insert into ip_allow values( "::1", Datetime("now"), 0, Datetime("now"),Datetime("now","+100 years"), "Local development IP address - Always Allow" );');

      ExecSQL;
    end;
  end;
end;

