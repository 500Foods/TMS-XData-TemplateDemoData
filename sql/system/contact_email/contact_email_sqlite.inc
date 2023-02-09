  // contact_email
  with FDQuery1 do
  begin

    SQL.Clear;
    SQL.Add('select '+
            '  value '+
            'from '+
            '  contact '+
            'where '+
            '  (person_id = :PERSONID) '+
            '  and (list_contact = 1) '+
            'order by '+
            '  preference;'
           );

  end;
