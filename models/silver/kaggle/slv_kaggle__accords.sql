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

cleaned as(
    select
        lower(trim(item_name)) as accord_name
    from extended
),

id_generated as(
    select distinct
          {{ dbt_utils.generate_surrogate_key(['accord_name']) }} as accord_id
        , accord_name
    from cleaned
    where accord_name != ''
)

select * from id_generated