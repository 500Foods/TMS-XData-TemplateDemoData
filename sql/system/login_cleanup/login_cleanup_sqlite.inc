  // login_cleanup
  with FDQuery1 do
  begin

    SQL.Clear;

    // We don't need to keep these around any longer than necessary

    SQL.Add('delete from '+
            '  login_fail '+
            'where '+
            '  attempted < Datetime("now", "-24 hours", "localtime");'
           );

    SQL.Add('delete from '+
            '  login_fail '+
            'where '+
            '  (ip_address = :IPADDRESS) '+
            '  and (login_id = :LOGINID); '
           );

    SQL.Add('delete from '+
            '  login_history '+
            'where '+
            '  logged_in < Datetime("now", "-90 days", "localtime");'
           );

    SQL.Add('delete from '+
            '  ip_block '+
            'where '+
            '  valid_until < Datetime("now", "-7 days", "localtime");'
           );

    SQL.Add('delete from '+
            '  ip_allow '+
            'where '+
            '  valid_until < Datetime("now", "-7 days", "localtime");'
           );

    SQL.Add('delete from '+
            '  token '+
            'where '+
            '  valid_until < Datetime("now", "-24 hours", "localtime");'
           );
  end;