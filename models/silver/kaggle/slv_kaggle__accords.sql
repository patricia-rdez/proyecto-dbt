with accords as(
    select
        accords
    from {{ ref('stg_kaggle__perfumes') }}
    where accords is not null
),

extended as(
    select
        split_part(a.value,':',1) as accord_name
    from accords, lateral split_to_table(accords.accords,'|') as a
),

cleaned as(
    select
          lower(trim(accord_name)) as accord_name
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