  // login_fail_check
  with FDQuery1 do
  begin

    SQL.Clear;
    SQL.Add('select '+
            '  count(*) attempts '+
            'from '+
            '  login_fail '+
            'where '+
            '  (login_id = :LOGINID) '+
            '  and (ip_address = :IPADDRESS) '+
            '  and (attempted > Datetime("now", "-10 minutes", "localtime"));'
           );

  end;