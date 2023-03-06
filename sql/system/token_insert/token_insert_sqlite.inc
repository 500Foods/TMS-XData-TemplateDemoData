// [query] token_insert

if (DatabaseEngine = 'sqlite') then
begin

  with Query1 do
  begin

    SQL.Clear;
    SQL.Add('insert into '+
            '  token '+
            '    (token_hash, valid_after, valid_until, person_id, application, version) '+
            'values( '+
            '  :TOKENHASH, '+
            '  :VALIDAFTER, '+
            '  :VALIDUNTIL, '+
            '  :PERSONID, '+
            '  :APPLICATION, '+
            '  :VERSION '+
            ');'
           );

  end;
end;