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
          perfume_id
        , lower(trim(item_name))        as accord_name
        , try_to_number(item_value)     as strength
        , position
    from extended
),

joined as(
    select
          perfume_id
        , {{ dbt_utils.generate_surrogate_key(['accord_name']) }} as accord_id
        , strength
        , position
    from cleaned
    where accord_name != ''
),

id_generated as(
    select
          {{ dbt_utils.generate_surrogate_key(['perfume_id', 'accord_id']) }} as perfume_accord_id
        , perfume_id
        , accord_id
        , strength
        , position
    from joined
)

select * from id_generated