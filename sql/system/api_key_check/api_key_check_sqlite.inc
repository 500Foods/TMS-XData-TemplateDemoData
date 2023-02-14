// [query] api_key_check

if (DatabaseEngine = 'sqlite') then
begin

  with Query1 do
  begin

    SQL.Clear;
    SQL.Add('select '+
            '  application, Datetime(valid_until, "localtime") valid_until '+
            'from '+
            '  api_key '+
            'where '+
            '  lower(api_key) = :APIKEY '+
            '  and (valid_after < Datetime("now")) '+
            '  and (valid_until > Datetime("now"));'
           );

  end;
end;
