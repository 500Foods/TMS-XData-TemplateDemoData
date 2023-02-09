// [query] ip_block_check

if (ServerContainer.DatabaseEngine = 'sqlite') then
begin

  with Query1 do
  begin

    SQL.Clear;
    SQL.Add('select '+
            '  valid_until '+
            'from '+
            '  ip_block '+
            'where '+
            '  ip_address = :IPADDRESS '+
            '  and (valid_after < current_timestamp) '+
            '  and (valid_until > current_timestamp);'
           );

  end;
end;
