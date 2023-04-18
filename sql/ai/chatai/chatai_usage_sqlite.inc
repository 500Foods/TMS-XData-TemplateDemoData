// [query] chatai_usage

if (MainForm.DatabaseEngine = 'sqlite') then
begin

  with Query1 do
  begin

    SQL.Clear;
    SQL.Add('select '+
            '  "7 days" period, '+
            '  count(*) requests, '+
            '  coalesce(sum(cost_total),0) cost '+
            ' from '+
            '   chatai_history '+
            ' WHERE '+
            '   last_modified BETWEEN datetime("now", "-7 days") AND datetime("now") '+

            'UNION '+

            'select '+
            '  "30 days" period, '+
            '  count(*) requests, '+
            '  coalesce(sum(cost_total),0) cost '+
            ' from '+
            '   chatai_history '+
            ' WHERE '+
            '   last_modified BETWEEN datetime("now", "-30 days") AND datetime("now") '+

            'UNION '+

            'select '+
            '  "all" period, '+
            '  count(*) requests, '+
            '  coalesce(sum(cost_total),0) cost '+
            ' from '+
            '   chatai_history;'
           );

  end;
end;


