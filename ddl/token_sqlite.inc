  // token
  with FDQuery1 do
  begin

    SQL.Clear;
    SQL.Add('create table if not exists token ('+
            '  token_hash                 text        NOT NULL, '+
            '  valid_after                text        NOT NULL, '+
            '  valid_until                text        NOT NULL, '+
            '  person_id                  text        NOT NULL, '+
            '  CONSTRAINT constraint_name PRIMARY KEY (token_hash) '+
            ');'
           );
    ExecSQL;

  end;

  // Note:
  // We don't really have any reason to create sample data here.

