with perfumes as(
    select
          perfume_id
        , slug
        , perfume_name
        , brand_name
        , release_year
        , collection_name
        , gender
        , url
        , description
        , captured_at_utc
        , date_load
    from {{ ref('stg_kaggle__perfumes') }}
),

cleaned as(
    select
          perfume_id
        , slug
        , perfume_name
        , lower(brand_name) as brand_key
        , case 
            when release_year < 1500 then null else release_year 
          end as release_year
        , lower(collection_name) as collection_key
        , lower(gender) as gender
        , url
        , description
    from perfumes
    qualify row_number() over (partition by perfume_id order by captured_at_utc desc, date_load desc) = 1
),

joined as(
    select
          perfume_id
        , slug
        , perfume_name
        , {{ dbt_utils.generate_surrogate_key(['brand_key']) }} as brand_id
        , release_year
        , case
              when collection_key is not null
              then {{ dbt_utils.generate_surrogate_key(['brand_key', 'collection_key']) }}
          end                                                  as collection_id
        , gender
        , url
        , description
    from cleaned
)

select * from joined