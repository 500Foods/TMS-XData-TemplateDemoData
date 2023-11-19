// [query] log_messaging

if (MainForm.DatabaseEngine = 'sqlite') then
begin

  with Query1 do
  begin

    SQL.Clear;
    SQL.Add('insert into '+
            '  messaging '+
            '    (service, created_at, MessageStatus, ErrorMessage, ErrorCode, Direction, RawDlrDoneDate, SmsStatus, SmsSid, SmsMessageSid, AccountSid, MessageSid, MessagingServiceSid, Body, '+
            '     ToNum, ToCountry, ToState, ToCity, ToZip,'+
            '     FromNum, FromCountry, FromState, FromCity, FromZip, '+
            '     NumSegments, NumMedia, Price, PriceUnit, AddOns, Uri, Resource, ApiVersion )'+
            'values( '+
            '  :service, '+
            '  Datetime("now"), '+
            '  :MessageStatus, '+
            '  :ErrorMessage, '+
            '  :ErrorCode, '+
            '  :Direction, '+
            '  :RawDlrDoneDate, '+
            '  :SmsStatus, '+
            '  :SmsSid, '+
            '  :SmsMessageSid, '+
            '  :AccountSid, '+
            '  :MessageSid, '+
            '  :MessagingServiceSid, '+
            '  :Body, '+
            '  :ToNum, '+
            '  :ToCountry, '+
            '  :ToState, '+
            '  :ToCity, '+
            '  :ToZip, '+
            '  :FromNum, '+
            '  :FromCountry, '+
            '  :FromState, '+
            '  :FromCity, '+
            '  :FromZip, '+
            '  :NumSegments, '+
            '  :NumMedia, '+
            '  :Price, '+
            '  :PriceUnits, '+
            '  :AddOns, '+
            '  :Uri, '+
            '  :Resource, '+
            '  :ApiVersion '+
            ');'
           );

  end;
end;


