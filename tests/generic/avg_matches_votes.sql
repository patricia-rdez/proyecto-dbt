{% test avg_matches_votes(model, column_name, metric, values, tolerance=000.1) %}

    with calc as(
        select
              {{ column_name }}                           as avg_source
            , {{ avg_from_votes(metric,values) }}   as avg_calc
        from {{ model }}
    )
    
    select * 
    from calc
    where avg_source is not null 
        and abs(avg_source - avg_calc) > {{ tolerance }}

{% endtest %}