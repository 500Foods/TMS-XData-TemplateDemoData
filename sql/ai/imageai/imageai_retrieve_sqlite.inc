// [query] imageai_retrieve

if (MainForm.DatabaseEngine = 'sqlite') then
begin

  with Query1 do
  begin

    SQL.Clear;
    SQL.Add('SELECT '+
            '  cast(generated_image as blob) generated_image '+
            'FROM '+
            '  imageai_history '+
            'WHERE '+
            '  chat_id = :CHATID;'
           );

  end;
end;

