with brands as(
    select
          lower(brand_name) as brand_key
        , brand_name
        , count(*)         as num_perfumes
    from {{ ref('stg_kaggle__perfumes') }}
    where brand_name is not null
    group by lower(brand_name), brand_name
),

 cleaned as(
    select
          brand_key
        , brand_name
    from brands
    qualify row_number() over(partition by brand_key order by num_perfumes desc, brand_name) = 1
    -- si hay dos marcas con el mismo key nos quedamos con la escritura que se repita más veces
 ),

id_generated as(
    select
          {{ dbt_utils.generate_surrogate_key(['brand_key']) }} as brand_id
        , brand_name  
    from cleaned
)

select * from id_generated