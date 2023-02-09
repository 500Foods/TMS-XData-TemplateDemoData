// [query] login_history_insert

if (ServerContainer.DatabaseEngine = 'sqlite') then
begin

  with Query1 do
  begin

    SQL.Clear;
    SQL.Add('insert into '+
            '  login_history '+
            '    (logged_in, person_id, ip_address) '+
            'values( '+
            '  :LOGGEDIN, '+
            '  :PERSONID, '+
            '  :IPADDRESS '+
            ');'
           );

  end;
end;
