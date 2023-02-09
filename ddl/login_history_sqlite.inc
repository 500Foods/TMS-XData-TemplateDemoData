  // login_history
  with FDQuery1 do
  begin

    SQL.Clear;
    SQL.Add('create table if not exists login_history ('+
            '  logged_in                  text        NOT NULL, '+
            '  person_id                  integer     NOT NULL, '+
            '  ip_address                 text        NOT NULL, '+
            '  CONSTRAINT constraint_name PRIMARY KEY (logged_in, person_id, ip_address) '+
            ');'
           );
    ExecSQL;

  end;

  // Note:
  // We don't really have any reason to create sample data here.

