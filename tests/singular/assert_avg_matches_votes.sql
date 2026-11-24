with calc as(
    select
          perfume_id
        , captured_at_utc
        , metric
        , sum(score * vote_count) / nullif(sum(vote_count), 0) as avg_calc
from {{ ref('slv_kaggle__perfume_metric_votes') }}
group by 1, 2, 3
),

source_avgs as (
    select 
          perfume_id
        , captured_at_utc
        , metric
        , avg_value
    from {{ ref('slv_kaggle__perfume_metrics') }}
    unpivot (avg_value for metric in (rating_avg, longevity_avg, sillage_avg, price_value_avg))
)
    
select 
      s.*
    , c.avg_calc
from source_avgs s
join calc c
    on  c.perfume_id = s.perfume_id
    and c.captured_at_utc = s.captured_at_utc
    and c.metric     = lower(replace(s.metric, '_AVG', ''))
where abs(s.avg_value - c.avg_calc) > 0.001