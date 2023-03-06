// [query] contact

if (MainForm.DatabaseEngine = 'sqlite') then
begin

  with Query1 do
  begin

    SQL.Clear;
    SQL.Add('SELECT '+
            '  c.contact_id, '+
            '  c.last_modified, '+
            '  c.last_modifier, '+
            '  c.list_contact, '+
            '  c.value, '+
            '  c.preference, '+
            '  c.login_use, '+
            '  m.account_name last_modifier_account, '+
            '  l.value contact_type, '+
            '  l.attributes contact_attributes '+
            'FROM '+
            '  contact c '+
            '  LEFT OUTER JOIN '+
            '    person m '+
            '      on c.last_modifier = m.person_id '+
            '  LEFT OUTER JOIN '+
            '    list l '+
            '      on l.list_id = 1 '+
            ' 	   and c.list_contact = l.lookup_id '+
            'WHERE '+
            '  c.person_id = :PERSONID '+
            'ORDER BY '+
            '  c.preference; '
           );

  end;
end;
