// [query] api_key_check

if (ServerContainer.DatabaseEngine = 'sqlite') then
begin

  with Query1 do
  begin

    SQL.Clear;
    SQL.Add('select '+
            '  api_key '+
            'from '+
            '  api_key '+
            'where '+
            '  lower(api_key) = :APIKEY '+
            '  and (valid_after < current_timestamp) '+
            '  and (valid_until > current_timestamp);'
           );

  end;
end;
