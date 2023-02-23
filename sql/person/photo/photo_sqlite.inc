// [query] photo

if (MainForm.DatabaseEngine = 'sqlite') then
begin

  with Query1 do
  begin

    SQL.Clear;
    SQL.Add('SELECT '+
            '  cast(photo_datauri as blob) photo_datauri '+
            'FROM '+
            '  photo '+
            'WHERE '+
            '	 person_id = :PERSONID '+
            '	 and photo_type = 1; '
           );

  end;
end;
