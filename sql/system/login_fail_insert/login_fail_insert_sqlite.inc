// [query] login_fail_insert

if (DatabaseEngine = 'sqlite') then
begin

  with Query1 do
  begin

    SQL.Clear;
    SQL.Add('insert into '+
            '  login_fail '+
            '    (login_id, ip_address, attempted) '+
            'values( '+
            '  :LOGINID, '+
            '  :IPADDRESS, '+
            '  Datetime("now") '+
            ');'
           );

  end;
end;
