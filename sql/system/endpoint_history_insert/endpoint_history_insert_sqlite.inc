// [query] endpoint_history_insert

if (ServerContainer.DatabaseEngine = 'sqlite') then
begin

  with Query1 do
  begin

    SQL.Clear;
    SQL.Add('insert into '+
            '  endpoint_history '+
            '    (endpoint, accessed, execution_ms, ip_address, details) '+
            'values( '+
            '  :ENDPOINT, '+
            '  :ACCESSED, '+
            '  :EXECUTIONMS, '+
            '  :IPADDRESS, '+
            '  :DETAILS '+
            ');'
           );

  end;
end;
