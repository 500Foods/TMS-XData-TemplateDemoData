// [query] role

if (MainForm.DatabaseEngine = 'sqlite') then
begin

  with Query1 do
  begin

    SQL.Clear;
    SQL.Add('SELECT '+
            '  pr.role_id, '+
            '  pr.valid_after, '+
            '  pr.valid_until, '+
            '  pr.last_modified, '+
            '  pr.last_modifier, '+
            '  m.account_name last_modifier_account, '+
            '  r.name, '+
            '  r.icon '+
            'FROM '+
            '  person_role pr '+
            '  LEFT OUTER JOIN '+
            '    person m '+
            '      on pr.last_modifier = m.person_id '+
            '  LEFT OUTER JOIN '+
            '    role r '+
            '      on pr.role_id = r.role_id '+
            'WHERE '+
            '  pr.person_id = :PERSONID '+
            'ORDER BY '+
            '  pr.valid_after; '
           );

  end;
end;
