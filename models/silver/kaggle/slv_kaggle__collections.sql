with collections as(
    select
          lower(collection_name)    as collection_key
        , collection_name
        , count(*)                  as num_perfumes
        , lower(brand_name)         as brand_key
    from {{ ref('stg_kaggle__perfumes') }}
    where collection_name is not null
    group by lower(collection_name), collection_name, lower(brand_name)
),

cleaned as(
    select
          collection_key
        , collection_name
        , brand_key
    from collections
    qualify row_number() over(partition by collection_key, brand_key order by num_perfumes desc, collection_name) = 1
    -- si hay dos colecciones con el mismo key nos quedamos con la escritura que se repita más veces
 ),

id_generated as(
    select
          {{ dbt_utils.generate_surrogate_key(['brand_key', 'collection_key']) }} as collection_id
        , collection_name
        , {{ dbt_utils.generate_surrogate_key(['brand_key']) }} as brand_id
    from cleaned
)

select * from id_generated