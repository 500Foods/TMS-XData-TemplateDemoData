// [table] messaging

TableName := 'messaging';

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
                '  service                    text      NOT NULL, '+
                '  created_at                 text, '+
                '  MessageStatus              text, '+
                '  ErrorMessage               text, '+
                '  ErrorCode                  text, '+
                '  Direction                  text, '+
                '  RawDlrDoneDate             text, '+
                '  SmsStatus                  text, '+
                '  SmsSid                     text, '+
                '  SmsMessageSid              text, '+
                '  AccountSid                 text, '+
                '  MessageSid                 text, '+
                '  MessagingServiceSid        text, '+
                '  Body                       text, '+
                '  ToNum                      text, '+
                '  ToCountry                  text, '+
                '  ToState                    text, '+
                '  ToCity                     text, '+
                '  ToZip                      text, '+
                '  FromNum                    text, '+
                '  FromCountry                text, '+
                '  FromState                  text, '+
                '  FromCity                   text, '+
                '  FromZip                    text, '+
                '  NumSegments                text, '+
                '  NumMedia                   text, '+
                '  Price                      text, '+
                '  PriceUnit                  text, '+
                '  AddOns                     text, '+
                '  Uri                        text, '+
                '  Resource                   text, '+
                '  ApiVersion                 text '+
                ');'
               );
        ExecSQL;

        // Try it again
        SQL.Clear;
        SQL.Add('select count(*) records from '+TableName+';');
        Open;
      end;
    end;
  end;
end;

