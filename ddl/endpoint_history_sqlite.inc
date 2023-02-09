  // endpoint_history
  with FDQuery1 do
  begin

    SQL.Clear;
    SQL.Add('create table if not exists endpoint_history ('+
            '  endpoint                   text        NOT NULL, '+
            '  accessed                   text        NOT NULL, '+
            '  execution_ms               integer     NOT NULL, '+
            '  ip_address                 text        NOT NULL, '+
            '  details                    text                  '+
            ');'
           );
    ExecSQL;

  end;

  // Note:
  // We don't really have any reason to create sample data here.

