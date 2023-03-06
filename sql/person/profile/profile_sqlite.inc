// [query] profile

if (MainForm.DatabaseEngine = 'sqlite') then
begin

  with Query1 do
  begin

    SQL.Clear;
    SQL.Add('SELECT '+
            '  p.last_name, '+
            '  p.first_name, '+
            '  p.middle_name, '+
            '  p.birthdate, '+
            '  p.account_name, '+
            '  p.last_modified, '+
            '  p.last_modifier, '+
            '  m.account_name last_modifier_account '+
            'FROM '+
            '  person p '+
            '  LEFT OUTER JOIN '+
            '    person m '+
            '      on p.last_modifier = m.person_id '+
            'WHERE '+
            '  p.person_id = :PERSONID; '
           );

  end;
end;
