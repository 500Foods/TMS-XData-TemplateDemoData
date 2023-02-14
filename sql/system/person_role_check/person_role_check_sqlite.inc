// [query] role_check

if (DatabaseEngine = 'sqlite') then
begin

  with Query1 do
  begin

    SQL.Clear;
    SQL.Add('select '+
            '  role_id, valid_until '+
            'from '+
            '  person_role '+
            'where '+
            '  person_id = :PERSONID '+
            '  and (valid_after < Datetime("now")) '+
            '  and (valid_until > Datetime("now")) '+
            'order by '+
            '  role_id;'
           );

  end;
end;
