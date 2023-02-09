// [query] ip_allow_check

if (ServerContainer.DatabaseEngine = 'sqlite') then
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
            '  and (valid_after < current_timestamp) '+
            '  and (valid_until > current_timestamp);'
           );

  end;
end;