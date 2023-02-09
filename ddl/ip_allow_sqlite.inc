  // ip_allow
  with FDQuery1 do
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
    SQL.Add('select '+
            '  count(*) records '+
            'from '+
            '  ip_allow;'
           );
    Open;

    if FieldByName('records').AsInteger = 0 then
    begin
      SQL.Clear;

      // Just as an example
      SQL.Add('insert into ip_allow values( "127.0.0.1", current_timestamp, 0, current_timestamp, "2100-01-01", "Local development IP address - Always Allow" );');

      ExecSQL;
    end;
  end;
