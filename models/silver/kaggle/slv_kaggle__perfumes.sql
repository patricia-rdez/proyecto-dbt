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
        , brand_name
        , release_year
        , collection_name
        , lower(gender) as gender
        , url
        , description
    from perfumes
    qualify row_number() over (partition by perfume_id order by captured_at_utc desc) = 1 -- si hago incrementalidad poner date_load
),

joined as(
    select
          p.perfume_id
        , p.slug
        , p.perfume_name
        , b.brand_id
        , p.release_year
        , c.collection_id
        , p.gender
        , p.url
        , p.description
    from cleaned p
    left join {{ ref('slv_kaggle__brands') }} b
        on p.brand_name = b.brand_name
    left join {{ ref('slv_kaggle__collections') }} c
        on p.collection_name = c.collection_name
)

select * from joined