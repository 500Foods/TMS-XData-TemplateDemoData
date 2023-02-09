// [query] token_insert

if (ServerContainer.DatabaseEngine = 'sqlite') then
begin

  with Query1 do
  begin

    SQL.Clear;
    SQL.Add('insert into '+
            '  token '+
            '    (token_hash, valid_after, valid_until, person_id) '+
            'values( '+
            '  :TOKENHASH, '+
            '  :VALIDAFTER, '+
            '  :VALIDUNTIL, '+
            '  :PERSONID '+
            ');'
           );

  end;
end;