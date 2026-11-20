with collections as(
    select
          lower(collection_name)    as collection_key
        , collection_name
        , count(*)                  as num_perfumes
        , lower(brand_name)         as brand_name
    from {{ ref('stg_kaggle__perfumes') }}
    where collection_name is not null
    group by lower(collection_name), collection_name, lower(brand_name)
),

joined as(
    select
          c.collection_key
        , c.collection_name
        , c.num_perfumes
        , b.brand_id
    from collections c
    left join {{ ref('slv_kaggle__brands') }} b
    on c.brand_name = lower(b.brand_name)
),

cleaned as(
    select
          collection_key
        , collection_name
        , brand_id
    from joined
    qualify row_number() over(partition by collection_key order by num_perfumes desc, collection_name) = 1
 ),

id_generated as(
    select
          {{ dbt_utils.generate_surrogate_key(['collection_key']) }} as collection_id
        , collection_name
        , brand_id
    from cleaned
)

select * from id_generated