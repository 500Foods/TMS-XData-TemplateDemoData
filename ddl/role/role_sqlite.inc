// [table] role

if (DatabaseEngine = 'sqlite') then
begin

  with Query1 do
  begin

    SQL.Clear;
    SQL.Add('create table if not exists role ('+
            '  role_id                    integer     NOT NULL, '+
            '  last_modified              text        NOT NULL, '+
            '  last_modifier              integer     NOT NULL, '+
            '  name                       text        NOT NULL, '+
            '  icon                       text        NOT NULL, '+
            '  CONSTRAINT constraint_name PRIMARY KEY (role_id), '+
            '  UNIQUE(name) '+
            ');'
           );
    ExecSQL;

    SQL.Clear;
    SQL.Add('select count(*) records from role;');
    Open;

    if FieldByName('records').AsInteger = 0 then
    begin
      SQL.Clear;

      // Default roles
      SQL.Add('insert into role values( 0, Datetime("now"), 0, "Login",         "<i class=""fa-solid fa-right-to-braket""></i>" );');
      SQL.Add('insert into role values( 1, Datetime("now"), 0, "Administrator", "<i class=""fa-solid fa-user-gear""></i>"       );');
      SQL.Add('insert into role values( 2, Datetime("now"), 0, "Manager",       "<i class=""fa-solid fa-user-clock""></i>"      );');
      SQL.Add('insert into role values( 3, Datetime("now"), 0, "Supervisor",    "<i class=""fa-solid fa-user-tag""></i>"        );');
      SQL.Add('insert into role values( 4, Datetime("now"), 0, "Worker",        "<i class=""fa-solid fa-user""></i>"            );');

      ExecSQL;
    end;
  end;
end;
