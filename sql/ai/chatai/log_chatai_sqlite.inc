// [query] log_chatai

if (MainForm.DatabaseEngine = 'sqlite') then
begin

  with Query1 do
  begin

    SQL.Clear;
    SQL.Add('delete from '+
            '  chatai_history '+
            'where '+
            '  chat_id = :CHATID;'+
            ' '+
            'replace into '+
            '  chatai_history '+
            '    (chat_id, last_modified, last_modifier, model, model_actual, cost_prompt, cost_completion, cost_total, '+
            '    token_prompt, token_completion, token_total, conversation, context, response, reason ) '+
            'values( '+
            '  :CHATID, '+
            '  :LASTMODIFIED, '+
            '  :LASTMODIFIER, '+
            '  :MODEL, '+
            '  :MODELACTUAL, '+
            '  :COSTPROMPT, '+
            '  :COSTCOMPLETION, '+
            '  :COSTTOTAL, '+
            '  :TOKENPROMPT, '+
            '  :TOKENCOMPLETION, '+
            '  :TOKENTOTAL, '+
            '  :CONVERSATION, '+
            '  :CONTEXT, '+
            '  :RESPONSE, '+
            '  :REASON '+
            ');'
           );

  end;
end;


