// [query] endpoint_history_insert

if (DatabaseEngine = 'sqlite') then
begin

  with Query1 do
  begin

    SQL.Clear;
    SQL.Add('insert into '+
            '  endpoint_history '+
            '    (endpoint, accessed, execution_ms, ip_address, application, database_name, database_engine, details) '+
            'values( '+
            '  :ENDPOINT, '+
            '  :ACCESSED, '+
            '  :EXECUTIONMS, '+
            '  :IPADDRESS, '+
            '  :APPLICATION, '+
            '  :DATABASENAME, '+
            '  :DATABASEENGINE, '+
            '  :DETAILS '+
            ');'
           );

  end;
end;
