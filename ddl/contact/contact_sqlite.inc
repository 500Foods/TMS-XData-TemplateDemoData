// [table] contact
//
// list_contact refers to the list table, containing arbitrary lists of things.
// In this case, the list includes things like 'email', 'telephone','fax', 'home', etc.
// preference is where the sort order is kept.

TableName := 'contact';

if (DatabaseEngine = 'sqlite') then
begin

  with Query1 do
  begin

    // Check if the table exists
    SQL.Clear;
    SQL.Add('select count(*) records from '+TableName+';');
    try
      Open;
      LogEvent('...'+TableName+' ('+IntToStr(FieldByName('records').AsInteger)+' records)');

    except on E:Exception do
      begin
        LogEvent('...'+TableName+' (CREATE)');
        SQL.Clear;
        SQL.Add('create table if not exists '+TableName+' ( '+
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

        // Try it again
        SQL.Clear;
        SQL.Add('select count(*) records from '+TableName+';');
        Open;
      end;
    end;

    // Populate empty table with sample data
    if (FieldByName('records').AsInteger = 0) then
    begin
      LogEvent('...'+TableName+' (POPULATE)');
      SQL.Clear;

      // SYSINSTALLER
      SQL.Add('insert into '+TableName+' values( 0, 0, Datetime("now"), 0, 0, "SYSINSTALLER", 0, 1 );');

      // Add E-Mail (with login ability) for all users
      SQL.Add('insert into '+TableName+' '+
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

      // Add Telephone (Work) (without login ability) for all users
      SQL.Add('insert into '+TableName+'  '+
              '  select '+
              '    person_id, '+
              '    2, '+
              '    Datetime("now"), '+
              '    0, '+
              '    3, '+
              '    "(" || cast(abs(random() % 899)+100 as TEXT) || ") " || cast(abs(random() % 899)+100 as TEXT) || "-" || cast(abs(random() % 8999)+1000 as TEXT), '+
              '    1, '+
              '    0 '+
              '  from person;'
            );

      // Add Telephone (Mobile) (without login ability) for all users
      SQL.Add('insert into '+TableName+' '+
              '  select '+
              '    person_id, '+
              '    3, '+
              '    Datetime("now"), '+
              '    0, '+
              '    4, '+
              '    "(" || cast(abs(random() % 899)+100 as TEXT) || ") " || cast(abs(random() % 899)+100 as TEXT) || "-" || cast(abs(random() % 8999)+1000 as TEXT), '+
              '    2, '+
              '    0 '+
              '  from person;'
            );

      // Add Telephone (Home) (without login ability) for all users
      SQL.Add('insert into '+TableName+' '+
              '  select '+
              '    person_id, '+
              '    4, '+
              '    Datetime("now"), '+
              '    0, '+
              '    5, '+
              '    "(" || cast(abs(random() % 899)+100 as TEXT) || ") " || cast(abs(random() % 899)+100 as TEXT) || "-" || cast(abs(random() % 8999)+1000 as TEXT), '+
              '    3, '+
              '    0 '+
              '  from person;'
            );

      ExecSQL;
    end;
  end;
end;

