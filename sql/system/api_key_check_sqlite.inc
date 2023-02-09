  // API Key Check
  with FDQuery1 do
  begin

    SQL.Clear;
    SQL.Add('select '+
            '  api_key '+
            'from '+
            '  api_key '+
            'where '+
            '  api_key = :APIKEY '+
            '  and (valid_after < current_timestamp) '+
            '  and (valid_until > current_timestamp);'
           );

  end;