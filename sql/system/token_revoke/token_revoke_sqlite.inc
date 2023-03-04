// [query] token_revoke

if (DatabaseEngine = 'sqlite') then
begin

  with Query1 do
  begin

    SQL.Clear;
    SQL.Add('delete from '+
            '  token '+
            'where '+
            '  token_hash = :TOKENHASH '+
            ';'
           );

  end;
end;