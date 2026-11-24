{{ config(materialized='ephemeral') }}

with source as(
    select
          perfume_id
        , accords
    from {{ ref('stg_kaggle__perfumes') }}
    where accords is not null
    qualify row_number() over (partition by perfume_id order by captured_at_utc desc, date_load desc) = 1
),

extended as(
    {{ list_to_name_and_weight('accords') }}
),

renamed as(
    select
          perfume_id
        , item_name     as accord_name
        , item_value    as strength
        , position
    from extended
)

select * from renamed