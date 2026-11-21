with perfumers as(
    select
        perfumers
    from {{ ref('stg_kaggle__perfumes') }}
    where perfumers is not null
),

extended as(
    select
        p.value as perfumer_name
    from perfumers, lateral split_to_table(perfumers.perfumers,'|') as p
),

cleaned as(
    select distinct
          lower(trim(perfumer_name)) as perfumer_key
        , trim(perfumer_name) as perfumer_name
    from extended
    where perfumer_name != '' -- al separar la lista, podrían salir filas vacías
),

id_generated as(
    select
          {{ dbt_utils.generate_surrogate_key(['perfumer_key']) }} as perfumer_id
        , perfumer_name
    from cleaned
)

select * from id_generated