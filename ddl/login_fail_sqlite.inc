  // login_fail
  with FDQuery1 do
  begin

    SQL.Clear;
    SQL.Add('create table if not exists login_fail ('+
            '  login_id                   text        NOT NULL, '+
            '  ip_address                 text        NOT NULL, '+
            '  attempted                  integer     NOT NULL, '+
            '  CONSTRAINT constraint_name PRIMARY KEY (login_id,ip_address,attempted) '+
            ');'
           );
    ExecSQL;

  end;

  // Note:
  // We don't really have any reason to create sample data here.

