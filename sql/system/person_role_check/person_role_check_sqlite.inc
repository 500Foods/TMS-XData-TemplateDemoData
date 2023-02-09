// [query] role_check

if (ServerContainer.DatabaseEngine = 'sqlite') then
begin

  with Query1 do
  begin

    SQL.Clear;
    SQL.Add('select '+
            '  role_id '+
            'from '+
            '  person_role '+
            'where '+
            '  person_id = :PERSONID '+
            '  and (valid_after < current_timestamp) '+
            '  and (valid_until > current_timestamp) '+
            'order by '+
            '  role_id;'
           );

  end;
end;
