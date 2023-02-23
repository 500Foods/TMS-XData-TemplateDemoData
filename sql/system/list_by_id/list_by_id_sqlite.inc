// [query] list_by_id

if (DatabaseEngine = 'sqlite') then
begin

  with Query1 do
  begin
    SQL.Clear;
    SQL.Add('select '+
            '  list_id, lookup_id, last_modified, last_modifier, preference, value, attributes '+
            'from '+
            '  list '+
            'where '+
            '  list_id = :LISTID '+
            ';'
           );

  end;
end;