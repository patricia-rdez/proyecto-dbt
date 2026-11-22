with cleaned as(
    select
          perfume_id
        , lower(trim(accord_name))  as accord_name
        , try_to_number(strength)   as strength
        , position
    from {{ ref('slv_int__accords_extended') }}
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