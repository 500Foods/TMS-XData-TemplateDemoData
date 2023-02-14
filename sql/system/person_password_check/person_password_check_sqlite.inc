// [query] person_password_check

if (DatabaseEngine = 'sqlite') then
begin

  with Query1 do
  begin

    SQL.Clear;
    SQL.Add('select '+
            '  first_name, '+
            '  middle_name, '+
            '  last_name, '+
            '  account_name '+
            'from '+
            '  person '+
            'where '+
            '  (person_id = :PERSONID) '+
            '  and (password_hash = :PASSWORDHASH);'
           );

  end;
end;