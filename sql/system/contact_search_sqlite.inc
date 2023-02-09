  // contact_search
  with FDQuery1 do
  begin

    SQL.Clear;
    SQL.Add('select '+
            '  distinct person_id '+
            'from '+
            '  contact '+
            'where '+
            '  (lower(value) = :LOGINID) '+
            '  and (login_use = 1);'
           );

  end;