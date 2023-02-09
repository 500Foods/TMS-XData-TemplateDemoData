  // login_fail_insert
  with FDQuery1 do
  begin

    SQL.Clear;
    SQL.Add('insert into '+
            '  login_fail '+
            '    (login_id, ip_address, attempted) '+
            'values( '+
            '  :LOGINID, '+
            '  :IPADDRESS, '+
            '  current_timestamp '+
            ');'
           );

  end;