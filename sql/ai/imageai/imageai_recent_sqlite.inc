// [query] imageai_recent

if (MainForm.DatabaseEngine = 'sqlite') then
begin

  with Query1 do
  begin

    SQL.Clear;
    SQL.Add('SELECT '+
            '  chat_id, '+
            '  prompt, '+
            '  generated_image, '+
            '  last_modified '+
            'FROM '+
            '  imageai_history '+
            'ORDER BY '+
            '  last_modified DESC '+
            'LIMIT '+
            '  25;'
           );

  end;
end;

