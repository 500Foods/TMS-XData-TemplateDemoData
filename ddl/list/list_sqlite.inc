// [table] list

if (DatabaseEngine = 'sqlite') then
begin

  with Query1 do
  begin

    SQL.Clear;
    SQL.Add('create table if not exists list ('+
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

    SQL.Clear;
    SQL.Add('select count(*) records from  list;');
    Open;

    if FieldByName('records').AsInteger = 0 then
    begin
      SQL.Clear;

      // list_id = 0 contains the names of the lists
      SQL.Add('insert into list values( 0, 0, Datetime("now"), 0, 0, "Lists", "");');
      SQL.Add('insert into list values( 0, 1, Datetime("now"), 0, 1, "Contact Types", "");');
      SQL.Add('insert into list values( 0, 2, Datetime("now"), 0, 2, "Organization Info", "");');
      SQL.Add('insert into list values( 0, 3, Datetime("now"), 0, 2, "Photo Types", "");');


      // Contact Types
      SQL.Add('insert into list values( 1,  0, Datetime("now"), 0,  0, "Login Name",         "<i class=""fa-solid fa-right-to-bracket""></i>");');
      SQL.Add('insert into list values( 1,  1, Datetime("now"), 0,  1, "E-Mail Address",     "<i class=""fa-solid fa-envelope""></i>");');
      SQL.Add('insert into list values( 1,  2, Datetime("now"), 0,  2, "Telephone (Work)",   "<i class=""fa-solid fa-phone""></i>");');
      SQL.Add('insert into list values( 1,  3, Datetime("now"), 0,  3, "Telephone (Mobile)", "<i class=""fa-solid fa-mobile-retro""></i>");');
      SQL.Add('insert into list values( 1,  4, Datetime("now"), 0,  4, "Telephone (Home)",   "<i class=""fa-solid fa-phonel""></i>");');
      SQL.Add('insert into list values( 1,  5, Datetime("now"), 0,  5, "Fax Machine (Work)", "<i class=""fa-solid fa-fax""></i>");');
      SQL.Add('insert into list values( 1,  6, Datetime("now"), 0,  6, "Fax Machine (Home)", "<i class=""fa-solid fa-fax""></i>");');
      SQL.Add('insert into list values( 1,  7, Datetime("now"), 0,  7, "Facebook",           "<i class=""fa-brands fa-facebook""></i>");');
      SQL.Add('insert into list values( 1,  8, Datetime("now"), 0,  8, "Twitter",            "<i class=""fa-brands fa-twitter""></i>");');
      SQL.Add('insert into list values( 1,  9, Datetime("now"), 0,  9, "Instagram",          "<i class=""fa-brands fa-instagram""></i>");');
      SQL.Add('insert into list values( 1, 10, Datetime("now"), 0,  10, "Work Address",      "<i class=""fa-solid fa-address-book""></i>");');
      SQL.Add('insert into list values( 1, 11, Datetime("now"), 0,  11, "Home Address",      "<i class=""fa-regular fa-address-book""></i>");');

      // Organization Info
      SQL.Add('insert into list values( 2,  0, Datetime("now"), 0,  0, "TMS WEB Core/XData Template", "Organization Name");');
      SQL.Add('insert into list values( 2,  1, Datetime("now"), 0,  1, "Template", "Organization Short Name");');
      SQL.Add('insert into list values( 2,  2, Datetime("now"), 0,  2, "TMS WEB Core and More", "Organization Slogan");');
      SQL.Add('insert into list values( 2,  3, Datetime("now"), 0,  3, "Copyright (c) 2023", "Copyright Notice");');

      // Photo Types
      SQL.Add('insert into list values( 3,  0, Datetime("now"), 0,  0, "Photo (Large)", "<i class=""fa-solid fa-user""></i>");');
      SQL.Add('insert into list values( 3,  1, Datetime("now"), 1,  0, "Photo (Thumbnail)", "<i class=""fa-solid fa-user""></i>");');

      ExecSQL;
    end;
  end;
end;

