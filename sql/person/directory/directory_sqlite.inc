// [query] directory

if (MainForm.DatabaseEngine = 'sqlite') then
begin

  with Query1 do
  begin

    SQL.Clear;
    SQL.Add('SELECT '+
            '  last_name as "Last Name", '+
            '  first_name as "First Name", '+
            '  middle_name as "Middle Name", '+
            '  list.value as "Type", '+
            '  contact.value as "Value" '+
            'FROM '+
            '  person '+
            '    LEFT OUTER JOIN contact '+
            '	     ON person.person_id = contact.person_id '+
            '	   LEFT OUTER JOIN list '+
            '	     ON list.list_id = 1 '+
            '	       AND contact.list_contact = list.lookup_id '+
            'ORDER BY '+
            '  last_name, '+
            '  contact.preference '
           );

  end;
end;
