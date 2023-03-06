// [query] login_count

if (MainForm.DatabaseEngine = 'sqlite') then
begin

  with Query1 do
  begin

    SQL.Clear;
    SQL.Add('SELECT '+
            '  count(*) logins '+
            'FROM '+
            '  login_history '+
            'WHERE '+
            '  person_id = :PERSONID '
           );

  end;
end;
