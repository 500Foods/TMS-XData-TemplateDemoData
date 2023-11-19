// [table] role

TableName := 'role';

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

      // Default roles
      SQL.Add('insert into '+TableName+' values( 0, Datetime("now"), 0, "Login",         ":Login" );');
      SQL.Add('insert into '+TableName+' values( 1, Datetime("now"), 0, "Administrator", ":Administrator" );');
      SQL.Add('insert into '+TableName+' values( 2, Datetime("now"), 0, "People",        ":People" );');
      SQL.Add('insert into '+TableName+' values( 3, Datetime("now"), 0, "Labels",        ":Labels" );');

      ExecSQL;
    end;
  end;
end;
