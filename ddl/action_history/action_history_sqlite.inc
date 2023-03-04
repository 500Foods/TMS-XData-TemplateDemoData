// [table] action_history
//
// We don't really have any reason to create sample data here.

if (DatabaseEngine = 'sqlite') then
begin

  with Query1 do
  begin

    SQL.Clear;
    SQL.Add('create table if not exists action_history ('+
            '  person_id                  integer     NOT NULL, '+
            '  ip_address                 text        NOT NULL, '+
            '  application                text        NOT NULL, '+
            '  version                    text        NOT NULL, '+
            '  accessed                   text        NOT NULL, '+
            '  actions                    text        NOT NULL '+
            ');'
           );

    ExecSQL;
  end;
end;

