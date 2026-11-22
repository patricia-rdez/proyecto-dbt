with cleaned as(
    select
          lower(trim(note_name))    as note_key
        , trim(note_name)           as note_name
        , count(*)                  as num_perfumes
    from {{ ref('slv_int__notes_extended') }}
    where note_name != ''
    group by 1, 2
),

deduplicated as(
    select
          note_key
        , note_name
    from cleaned
    qualify row_number() over(partition by note_key order by num_perfumes desc, note_name) = 1
),

id_generated as(
    select
          {{ dbt_utils.generate_surrogate_key(['note_key']) }} as note_id
        , note_name
    from deduplicated
)

select * from id_generated