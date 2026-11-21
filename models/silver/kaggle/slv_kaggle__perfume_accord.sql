with accords as(
    select
          perfume_id
        , accords
    from {{ ref('stg_kaggle__perfumes') }}
    where accords is not null
),

extended as(
    select
          perfume_id
        , split_part(a.value,':',1) as accord_name
        , split_part(a.value,':',2) as strength
        , a.index as position
    from accords, lateral split_to_table(accords.accords,'|') as a
),

cleaned as(
    select
          perfume_id
        , lower(trim(accord_name)) as accord_key
        , try_to_number(strength) as strength
        , position
    from extended
),

joined as(
    select
          perfume_id
        , {{ dbt_utils.generate_surrogate_key(['accord_key']) }} as accord_id
        , strength
        , position
    from cleaned
    where accord_key != ''
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