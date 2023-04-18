// [query] imageai_usage

if (MainForm.DatabaseEngine = 'sqlite') then
begin

  with Query1 do
  begin

    SQL.Clear;
    SQL.Add('select '+
            '  "7 days" period, '+
            '  count(*) requests, '+
            '  sum(cost_total) cost '+
            ' from '+
            '   imageai_history '+
            ' WHERE '+
            '   last_modified BETWEEN datetime("now", "-7 days") AND datetime("now") '+

            'UNION '+

            'select '+
            '  "30 days" period, '+
            '  count(*) requests, '+
            '  sum(cost_total) cost '+
            ' from '+
            '   imageai_history '+
            ' WHERE '+
            '   last_modified BETWEEN datetime("now", "-30 days") AND datetime("now") '+

            'UNION '+

            'select '+
            '  "all" period, '+
            '  count(*) requests, '+
            '  sum(cost_total) cost '+
            ' from '+
            '   imageai_history;'
           );

  end;
end;


