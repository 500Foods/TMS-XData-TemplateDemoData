// [table] person_role

TableName := 'person_role';

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
                '  role_id                    integer     NOT NULL, '+
                '  valid_after                text        NOT NULL, '+
                '  valid_until                text        NOT NULL, '+
                '  last_modified              text        NOT NULL, '+
                '  last_modifier              integer     NOT NULL, '+
                '  CONSTRAINT constraint_name PRIMARY KEY (person_id, role_id, valid_after) '+
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

      // Grant System Installer the role of Login(0), Administrator(1), People(2), and Labels(3)
      SQL.Add('insert into '+TableName+' values( 0, 0, Datetime("now"), Datetime("now", "+100 years"), Datetime("now"), 0);');
      SQL.Add('insert into '+TableName+' values( 0, 1, Datetime("now"), Datetime("now", "+100 years"), Datetime("now"), 0);');
      SQL.Add('insert into '+TableName+' values( 0, 2, Datetime("now"), Datetime("now", "+100 years"), Datetime("now"), 0);');
      SQL.Add('insert into '+TableName+' values( 0, 3, Datetime("now"), Datetime("now", "+100 years"), Datetime("now"), 0);');

      ExecSQL;
    end;
  end;
end;

