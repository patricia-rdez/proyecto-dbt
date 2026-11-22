with cleaned as(
    select
        lower(trim(accord_name)) as accord_name
    from {{ ref('slv_int__accords_extended') }}
),

id_generated as(
    select distinct
          {{ dbt_utils.generate_surrogate_key(['accord_name']) }} as accord_id
        , accord_name
    from cleaned
    where accord_name != ''
)

select * from id_generated