// [query] action_history_insert

if (DatabaseEngine = 'sqlite') then
begin

  with Query1 do
  begin

    SQL.Clear;
    SQL.Add('insert into '+
            '  action_history '+
            '    (person_id, ip_address, application, version, accessed, actions) '+
            'values( '+
            '  :PERSONID, '+
            '  :IPADDRESS, '+
            '  :APPLICATION, '+
            '  :VERSION, '+
            '  :ACCESSED, '+
            '  :ACTIONS '+
            ');'
           );

  end;
end;
