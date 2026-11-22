with cleaned as(
    select
          perfume_id
        , lower(trim(note_name))    as note_key
        , level
        , try_to_number(weight)     as weight
    from {{ ref('slv_int__notes_extended') }}
    where note_name != ''
),

deduplicated as(
    select
          perfume_id
        , note_key
        , level
        , max(weight)   as weight
    from cleaned
    group by 1,2,3
),

joined as(
    select
          perfume_id
        , {{ dbt_utils.generate_surrogate_key(['note_key']) }} as note_id
        , level
        , weight
    from deduplicated
),

id_generated as(
    select
          {{ dbt_utils.generate_surrogate_key(['perfume_id', 'note_id', 'level']) }} as perfume_note_id
        , perfume_id
        , note_id
        , level
        , weight
    from joined
)

select * from id_generated