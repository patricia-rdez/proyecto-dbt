with perfume_perfumer as(
    select
        perfume_id,
        perfumers
    from {{ ref('stg_kaggle__perfumes') }}
    where perfumers is not null
),

extended as(
    select
          perfume_id
        , lower(trim(p.value)) as perfumer_key
    from perfume_perfumer, lateral split_to_table(perfume_perfumer.perfumers,'|') as p
),

id_generated as(
    select
          perfume_id
        , {{ dbt_utils.generate_surrogate_key(['perfumer_key']) }} as perfumer_id -- se evita hacer join
    from extended 
)

select * from id_generated