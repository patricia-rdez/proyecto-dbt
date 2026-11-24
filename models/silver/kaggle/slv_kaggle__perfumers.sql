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
    select
          lower(trim(perfumer_name)) as perfumer_key
        , trim(perfumer_name) as perfumer_name
        , count(*) as num_perfumes
    from extended
    where trim(perfumer_name) != '' -- al separar la lista, podrían salir filas vacías
    group by 1,2
),

deduplicated as(
    select
          perfumer_key
        , perfumer_name
    from cleaned
    qualify row_number() over(partition by perfumer_key order by num_perfumes desc, perfumer_name) = 1
),

id_generated as(
    select
          {{ dbt_utils.generate_surrogate_key(['perfumer_key']) }} as perfumer_id
        , perfumer_name
    from deduplicated
)

select * from id_generated