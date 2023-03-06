// [table] person_role

if (DatabaseEngine = 'sqlite') then
begin

  with Query1 do
  begin

    SQL.Clear;
    SQL.Add('create table if not exists person_role ('+
            '  person_id                  integer     NOT NULL, '+
            '  role_id                    integer     NOT NULL, '+
            '  valid_after                text        NOT NULL, '+
            '  valid_until                text        NOT NULL, '+
            '  last_modified              text        NOT NULL, '+
            '  last_modifier              integer     NOT NULL, '+
            '  CONSTRAINT constraint_name PRIMARY KEY (person_id, role_id, valid_after) '+
            ');'
           );
    ExecSQL;

    SQL.Clear;
    SQL.Add('select count(*) records from person_role;');
    Open;

    if FieldByName('records').AsInteger = 0 then
    begin
      SQL.Clear;

      // Grant System Installer the role of Login(0), Administrator(1), People(2), and Labels(3)
      SQL.Add('insert into person_role values( 0, 0, Datetime("now"), Datetime("now", "+100 years"), Datetime("now"), 0);');
      SQL.Add('insert into person_role values( 0, 1, Datetime("now"), Datetime("now", "+100 years"), Datetime("now"), 0);');
      SQL.Add('insert into person_role values( 0, 2, Datetime("now"), Datetime("now", "+100 years"), Datetime("now"), 0);');
      SQL.Add('insert into person_role values( 0, 3, Datetime("now"), Datetime("now", "+100 years"), Datetime("now"), 0);');


      ExecSQL;
    end;
  end;
end;

