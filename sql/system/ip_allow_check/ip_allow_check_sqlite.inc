// [query] ip_allow_check

if (DatabaseEngine = 'sqlite') then
begin

  with Query1 do
  begin

    SQL.Clear;
    SQL.Add('select '+
            '  ip_address '+
            'from '+
            '  ip_allow '+
            'where '+
            '  ip_address = :IPADDRESS '+
            '  and (valid_after < Datetime("now")) '+
            '  and (valid_until > Datetime("now"));'
           );

  end;
end;