// [query] ip_block_insert

if (DatabaseEngine = 'sqlite') then
begin

  with Query1 do
  begin

    SQL.Clear;
    SQL.Add('delete from '+
            '  ip_block '+
            'where  '+
            '  (ip_address = :IPADDRESS) '+
            '  or (valid_until < Datetime("now")); '
           );
    SQL.Add('insert into '+
            '  ip_block '+
            '    (ip_address, last_modified, last_modifier, valid_after, valid_until, justification) '+
            'values( '+
            '  :IPADDRESS, '+
            '  Datetime("now"), '+
            '  1, '+
            '  Datetime("now"), '+
            '  Datetime("now", "+10 minutes"), '+
            '  :REASON); '
           );

  end;
end;

