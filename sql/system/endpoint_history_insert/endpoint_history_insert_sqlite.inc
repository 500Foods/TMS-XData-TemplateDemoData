// [query] endpoint_history_insert

if (DatabaseEngine = 'sqlite') then
begin

  with Query1 do
  begin

    SQL.Clear;
    SQL.Add('insert into '+
            '  endpoint_history '+
            '    (person_id, endpoint, accessed, execution_ms, ip_address, application, version, database_name, database_engine, details) '+
            'values( '+
            '  :PERSONID, '+
            '  :ENDPOINT, '+
            '  :ACCESSED, '+
            '  :EXECUTIONMS, '+
            '  :IPADDRESS, '+
            '  :APPLICATION, '+
            '  :VERSION, '+
            '  :DATABASENAME, '+
            '  :DATABASEENGINE, '+
            '  :DETAILS '+
            ');'
           );

  end;
end;
