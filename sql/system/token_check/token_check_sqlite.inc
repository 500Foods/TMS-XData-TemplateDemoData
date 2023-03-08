// [query] token_check

if (DatabaseEngine = 'sqlite') then
begin

  with Query1 do
  begin

    SQL.Clear;
    SQL.Add('select '+
            '  token_hash, valid_until '+
            'from '+
            '  token '+
            'where '+
            '  (token_hash = :TOKENHASH) '+
            '  and (ip_address = :IPADDRESS) '+
            '  and (Datetime("now") > valid_after) '+
            '  and (Datetime("now") < valid_until) '+
            ';'
           );

  end;
end;