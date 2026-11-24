
{{
    config(
        materialized='incremental',
        unique_key='perfume_votes_id',
        incremental_strategy='merge',
        on_schema_change='fail'
    )
}}

with votes as (
    select
          perfume_id
        , captured_at_utc
        , rating_b1, rating_b2, rating_b3, rating_b4, rating_b5
        , longevity_b1, longevity_b2, longevity_b3, longevity_b4, longevity_b5
        , sillage_b1, sillage_b2, sillage_b3, sillage_b4
        , price_value_b1, price_value_b2, price_value_b3, price_value_b4, price_value_b5
        , date_load
    from {{ ref('stg_kaggle__perfumes') }}

    {% if is_incremental() %}
    -- solo las cargas de bronze posteriores a la última ya procesada
    where date_load > (select max(date_load) from {{ this }})
    {% endif %}
),

cleaned as (
    select
          perfume_id
        , captured_at_utc
        , rating_b1, rating_b2, rating_b3, rating_b4, rating_b5
        , longevity_b1, longevity_b2, longevity_b3, longevity_b4, longevity_b5
        , sillage_b1, sillage_b2, sillage_b3, sillage_b4
        , price_value_b1, price_value_b2, price_value_b3, price_value_b4, price_value_b5
        , date_load
    from votes
    qualify row_number() over (partition by perfume_id, captured_at_utc order by date_load desc) = 1
),

unpivoted as (
    select 
          perfume_id
        , captured_at_utc
        , bucket_column
        , vote_count
        , date_load
    from cleaned
    unpivot (vote_count for bucket_column in (
          rating_b1, rating_b2, rating_b3, rating_b4, rating_b5
        , longevity_b1, longevity_b2, longevity_b3, longevity_b4, longevity_b5
        , sillage_b1, sillage_b2, sillage_b3, sillage_b4
        , price_value_b1, price_value_b2, price_value_b3, price_value_b4, price_value_b5
    ))
),

renamed as(
    select
          perfume_id
        , captured_at_utc
        , lower(regexp_replace(bucket_column, '_B[0-9]$', ''))        as metric
        , try_to_number(right(bucket_column, 1))::number(1,0)         as score
        , vote_count
        , date_load
    from unpivoted
)

select
      {{ dbt_utils.generate_surrogate_key(['perfume_id', 'captured_at_utc', 'metric', 'score']) }} as perfume_votes_id
    , perfume_id
    , captured_at_utc
    , metric
    , score
    , vote_count
    , date_load
from renamed