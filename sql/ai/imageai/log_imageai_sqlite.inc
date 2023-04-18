// [query] log_imageai

if (MainForm.DatabaseEngine = 'sqlite') then
begin

  with Query1 do
  begin

    SQL.Clear;
    SQL.Add('insert into '+
            '  imageai_history '+
            '    (chat_id, last_modified, last_modifier, model, model_actual, cost_total, prompt, generated_image ) '+
            'values( '+
            '  :CHATID, '+
            '  :LASTMODIFIED, '+
            '  :LASTMODIFIER, '+
            '  :MODEL, '+
            '  :MODELACTUAL, '+
            '  :COSTTOTAL, '+
            '  :PROMPT, '+
            '  :GENERATEDIMAGE '+
            ');'
           );

  end;
end;

