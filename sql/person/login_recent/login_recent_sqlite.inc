// [query] login_recent

if (MainForm.DatabaseEngine = 'sqlite') then
begin

  with Query1 do
  begin

    SQL.Clear;
    SQL.Add('SELECT '+
            '  logged_in, '+
            '  ip_address, '+
            '  application, '+
            '  version '+
            'FROM '+
            '  login_history '+
            'WHERE '+
            '  (person_id = :PERSONID) '+
            '  and (logged_in >= datetime("now" , "-7 days")) '+
            'ORDER BY '+
            '  logged_in DESC; '
           );

  end;
end;
