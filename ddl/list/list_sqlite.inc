// [table] list

TableName := 'list';

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
                '  list_id                    integer     NOT NULL, '+
                '  lookup_id                  integer     NOT NULL, '+
                '  last_modified              text        NOT NULL, '+
                '  last_modifier              integer     NOT NULL, '+
                '  preference                 integer     NOT NULL, '+
                '  value                      text        NOT NULL, '+
                '  attributes                 text                , '+
                '  CONSTRAINT constraint_name PRIMARY KEY (list_id,lookup_id) '+
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

      // list_id = 0 contains the names of the lists
      SQL.Add('insert into '+TableName+' values( 0, 0, Datetime("now"), 0, 0, "Lists", "");');
      SQL.Add('insert into '+TableName+' values( 0, 1, Datetime("now"), 0, 1, "Contact Types", "");');
      SQL.Add('insert into '+TableName+' values( 0, 2, Datetime("now"), 0, 2, "Organization Info", "");');
      SQL.Add('insert into '+TableName+' values( 0, 3, Datetime("now"), 0, 2, "Photo Types", "");');
      SQL.Add('insert into '+TableName+' values( 0, 4, Datetime("now"), 0, 2, "Custom Icons", "");');


      // Contact Types
      SQL.Add('insert into '+TableName+' values( 1,  0, Datetime("now"), 0,  0, "Login Name",            ":Login");');
      SQL.Add('insert into '+TableName+' values( 1,  1, Datetime("now"), 0,  1, "E-Mail Address (Work)", ":EMail");');
      SQL.Add('insert into '+TableName+' values( 1,  2, Datetime("now"), 0,  2, "E-Mail Address (Home)", ":EMailHome");');
      SQL.Add('insert into '+TableName+' values( 1,  3, Datetime("now"), 0,  3, "Telephone (Work)",      ":Telephone");');
      SQL.Add('insert into '+TableName+' values( 1,  4, Datetime("now"), 0,  4, "Telephone (Mobile)",    ":TelephoneMobile");');
      SQL.Add('insert into '+TableName+' values( 1,  5, Datetime("now"), 0,  5, "Telephone (Home)",      ":TelephoneHome");');
      SQL.Add('insert into '+TableName+' values( 1,  6, Datetime("now"), 0,  6, "Fax Machine (Work)",    ":Fax");');
      SQL.Add('insert into '+TableName+' values( 1,  7, Datetime("now"), 0,  7, "Fax Machine (Home)",    ":FaxHome");');
      SQL.Add('insert into '+TableName+' values( 1,  8, Datetime("now"), 0,  8, "Facebook",              ":Facebook");');
      SQL.Add('insert into '+TableName+' values( 1,  9, Datetime("now"), 0,  9, "Twitter",               ":Twitter");');
      SQL.Add('insert into '+TableName+' values( 1, 10, Datetime("now"), 0, 10, "Instagram",             ":Instagram");');
      SQL.Add('insert into '+TableName+' values( 1, 11, Datetime("now"), 0, 11, "Address (Work)",        ":Address");');
      SQL.Add('insert into '+TableName+' values( 1, 12, Datetime("now"), 0, 12, "Address (Home)",        ":AddressWork");');

      // Organization Info
      SQL.Add('insert into '+TableName+' values( 2,  0, Datetime("now"), 0,  0, "TMS WEB Core/XData Template", "Organization Name");');
      SQL.Add('insert into '+TableName+' values( 2,  1, Datetime("now"), 0,  1, "Template", "Organization Short Name");');
      SQL.Add('insert into '+TableName+' values( 2,  2, Datetime("now"), 0,  2, "TMS WEB Core and More", "Organization Slogan");');
      SQL.Add('insert into '+TableName+' values( 2,  3, Datetime("now"), 0,  3, "Copyright (c) 2023", "Copyright Notice");');

      // Photo Types
      SQL.Add('insert into '+TableName+' values( 3,  0, Datetime("now"), 0,  0, "Photo (Large)", ":User");');
      SQL.Add('insert into '+TableName+' values( 3,  1, Datetime("now"), 1,  0, "Photo (Thumbnail)", ":User");');

      ExecSQL;
    end;
  end;
end;

