with perfumes as(
    select
          perfume_id
        , slug
        , perfume_name
        , brand_id
        , release_year
        , collection_id
        , gender
        , url
        , description
    from {{ ref('slv_kaggle__perfumes') }}
),

brands as(
    select
          brand_id
        , brand_name  
    from {{ ref('slv_kaggle__brands') }}
),

collections as(
    select
          collection_id
        , collection_name
        , brand_id
    from {{ ref('slv_kaggle__collections') }}
),

brand_categories as (
    select
          brand_name
        , brand_category
    from {{ ref('brand_categories') }}
),

scores as(
    select *
    from {{ ref('int__perfume_scores') }}
),

joined as(
    select
          p.perfume_id
        , p.perfume_name
        , b.brand_name
        , coalesce(bc.brand_category, 'other')           as brand_category
        , c.collection_name
        , p.gender
        , p.release_year
        , floor(p.release_year / 10) * 10                as release_decade
        , s.dominant_season
        , s.dominant_daypart
        , s.rating_vote_count >= {{ var('min_votes') }}  as has_enough_votes
    from perfumes p
    left join brands b
        on p.brand_id = b.brand_id
    left join collections c
        on p.collection_id = c.collection_id
    left join brand_categories bc
        on lower(b.brand_name) = lower(trim(bc.brand_name))
    left join scores s
        on p.perfume_id = s.perfume_id
)

select * from joined