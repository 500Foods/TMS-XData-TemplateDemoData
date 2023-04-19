// [query] chatai_recent

if (MainForm.DatabaseEngine = 'sqlite') then
begin

  with Query1 do
  begin

    SQL.Clear;
    SQL.Add('SELECT '+
            '  chat_id, '+
            '  conversation, '+
            '  context, '+
            '  response, '+
            '  last_modified '+
            'FROM '+
            '  chatai_history '+
            'ORDER BY '+
            '  last_modified DESC '+
            'LIMIT '+
            '  100;'
           );

  end;
end;


