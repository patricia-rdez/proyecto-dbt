with perfumes as(
    select
          perfume_id
        , slug
        , perfume_name
        , brand_name
        , release_year
        , collection_name
        , gender_name
        , url
        , description
    from {{ ref('stg_kaggle__perfumes') }}
),

joined as(
    select
          p.perfume_id
        , p.slug
        , p.perfume_name
        , b.brand_id
        , p.release_year
        , c.collection_id
        , g.gender_id
        , p.url
        , p.description
    from perfumes p
    left join {{ ref('slv_kaggle__brands') }} b
        on p.brand_name = b.brand_name
    left join {{ ref('slv_kaggle__collections') }} c
        on p.collection_name = c.collection_name
    left join {{ ref('slv_kaggle__genders') }} g
        on p.gender_name = g.gender_name
)

select * from joined