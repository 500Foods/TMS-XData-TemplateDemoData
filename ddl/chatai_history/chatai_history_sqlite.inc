// [table] chatai_history
//
// No sample data

TableName := 'chatai_history';

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
                '  chat_id                    text        NOT NULL, '+
                '  last_modified              text        NOT NULL, '+
                '  last_modifier              integer     NOT NULL, '+
                '  model                      text        NOT NULL, '+
                '  model_actual               text                , '+
                '  cost_prompt                real        NOT NULL, '+
                '  cost_completion            real        NOT NULL, '+
                '  cost_total                 real        NOT NULL, '+
                '  token_prompt               integer     NOT NULL, '+
                '  token_completion           integer     NOT NULL, '+
                '  token_total                integer     NOT NULL, '+
                '  conversation               text        NOT NULL, '+
                '  context                    text                , '+
                '  response                   text        NOT NULL, '+
                '  reason                     text        NOT NULL, '+
                '  CONSTRAINT constraint_name PRIMARY KEY (chat_id) '+
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
//    if (FieldByName('records').AsInteger = 0) then
//    begin
//      LogEvent('...'+TableName+' (POPULATE)');
//      SQL.Clear;
//    end;
  end;
end;


