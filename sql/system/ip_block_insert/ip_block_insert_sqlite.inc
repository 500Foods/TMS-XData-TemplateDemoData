// [query] ip_block_insert

if (ServerContainer.DatabaseEngine = 'sqlite') then
begin

  with Query1 do
  begin

    SQL.Clear;
    SQL.Add('insert into '+
            ' ip_block '+
            '   (ip_address, last_modified, last_modifier, valid_after, valid_until, justification) '+
            'values( '+
            '  :IPADDRESS, '+
            '  current_timestamp, '+
            '  1, '+
            '  current_timestamp, '+
            '  Datetime("now", "+10 minutes", "localtime"), '+
            '  :REASON) '
           );

  end;
end;

