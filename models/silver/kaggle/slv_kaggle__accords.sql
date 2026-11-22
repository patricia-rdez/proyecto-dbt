with cleaned as(
    select
          lower(trim(accord_name))  as accord_key
        , trim(accord_name)         as accord_name
        , count(*)                  as num_perfumes
    from {{ ref('slv_int__accords_extended') }}
    where accord_name != ''
    group by 1,2
),

deduplicated as(
    select
          accord_key
        , accord_name
    from cleaned
    qualify row_number() over(partition by accord_key order by num_perfumes desc, accord_name) = 1
),

id_generated as(
    select
          {{ dbt_utils.generate_surrogate_key(['accord_key']) }} as accord_id
        , accord_name
    from deduplicated
)

select * from id_generated