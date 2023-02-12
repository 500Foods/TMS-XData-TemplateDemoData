// [table] contact
//
// list_contact refers to the list table, containing arbitrary lists of things.
// In this case, the list includes things like 'email', 'telephone','fax', 'home', etc.
// preference is where the sort order is kept.

if (DatabaseEngine = 'sqlite') then
begin

  with Query1 do
  begin

    SQL.Clear;
    SQL.Add('create table if not exists contact ('+
            '  person_id                  integer     NOT NULL, '+
            '  contact_id                 integer     NOT NULL, '+
            '  last_modified              text        NOT NULL, '+
            '  last_modifier              integer     NOT NULL, '+
            '  list_contact               integer     NOT NULL, '+
            '  value                      text        NOT NULL, '+
            '  preference                 integer     NOT NULL, '+
            '  login_use                  integer     NOT NULL, '+
            '  CONSTRAINT constraint_name PRIMARY KEY (person_id,contact_id) '+
            ');'
           );
    ExecSQL;

    SQL.Clear;
    SQL.Add('select count(*) records from contact;');
    Open;

    if FieldByName('records').AsInteger = 0 then
    begin
      SQL.Clear;

      // SYSINSTALLER
      SQL.Add('insert into contact values( 0, 0, Datetime("now"), 0, 0, "SYSINSTALLER", 0, 1 );');

      // Add email logins for all users
      SQL.Add('insert into contact  '+
              '  select '+
              '    person_id, '+
              '    1, '+
              '    Datetime("now"), '+
              '    0, '+
              '    1, '+
              '    lower(account_name) || "@company.com", '+
              '    0, '+
              '    1 '+
              '  from person;'
            );

      ExecSQL;
    end;
  end;
end;

