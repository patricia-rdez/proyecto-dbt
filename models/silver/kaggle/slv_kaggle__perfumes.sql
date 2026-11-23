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
    from {{ ref('stg_kaggle__perfumes') }}
),

cleaned as(
    select
          perfume_id
        , slug
        , perfume_name
        , lower(brand_name) as brand_key
        , release_year
        , lower(collection_name) as collection_key
        , lower(gender) as gender
        , url
        , description
    from perfumes
    qualify row_number() over (partition by perfume_id order by captured_at_utc desc) = 1 -- si hago incrementalidad poner date_load
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