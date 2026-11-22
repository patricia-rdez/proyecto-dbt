{{ config(materialized='ephemeral') }}

with source as(
    select
          perfume_id
        , accords
    from {{ ref('stg_kaggle__perfumes') }}
    where accords is not null
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