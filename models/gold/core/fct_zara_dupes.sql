with perfumes as (
    select 
          perfume_id
        , perfume_name
        , brand_name
        , brand_category
        , collection_name
        , gender
        , release_year
        , release_decade
        , dominant_season
        , dominant_daypart
        , has_enough_votes
    from {{ ref('dim_perfumes') }}
),

perfume_accords as (
    select 
          perfume_id
        , accord_id
        , strength
    from {{ ref('slv_kaggle__perfume_accord') }}
),

scores as (
    select
          perfume_id
        , captured_at_utc
        , rating_avg
        , rating_vote_count
        , bayesian_rating
        , longevity_avg
        , sillage_avg
        , price_value_avg
        , have_count
        , had_count
        , want_count
        , winter_share
        , spring_share
        , summer_share
        , autumn_share
        , dominant_season
        , dominant_daypart
    from {{ ref('int__perfume_scores') }}
),

zara as (
    select 
        p.perfume_id
    from perfumes p
    inner join scores s 
        on s.perfume_id = p.perfume_id
    where lower(p.brand_name) = 'zara'
      and s.rating_vote_count >= {{ var('min_votes') }}
),

originals as (
    select 
        p.perfume_id
    from perfumes p
    inner join scores s 
        on s.perfume_id = p.perfume_id
    where p.brand_category in ('designer', 'niche')
      and s.rating_vote_count >= {{ var('min_votes_original') }}
),

norms as (
    select
          perfume_id
        , sqrt(sum(strength * strength)) as norm
    from perfume_accords
    group by 1
),

zara_accords as (
    select 
          pa.perfume_id
        , pa.accord_id
        , pa.strength
    from perfume_accords pa
    inner join zara z 
        on z.perfume_id = pa.perfume_id
),

original_accords as (
    select 
          pa.perfume_id
        , pa.accord_id
        , pa.strength
    from perfume_accords pa
    inner join originals o 
        on o.perfume_id = pa.perfume_id
),

dot_products as (
    -- solo se cruzan los acordes que comparten: los demás aportan 0 al producto escalar
    select
          za.perfume_id                     as dupe_perfume_id
        , oa.perfume_id                     as original_perfume_id
        , sum(za.strength * oa.strength)    as dot_product
        , count(*)                          as shared_accords
    from zara_accords za
    inner join original_accords oa
        on oa.accord_id = za.accord_id
    group by 1, 2
),

similarity as (
    select
          d.dupe_perfume_id
        , d.original_perfume_id
        , d.shared_accords
        , d.dot_product / (norm_dupe.norm * norm_orig.norm) as similarity
    from dot_products d
    inner join norms norm_dupe 
        on norm_dupe.perfume_id = d.dupe_perfume_id
    inner join norms norm_orig 
        on norm_orig.perfume_id = d.original_perfume_id
),

bands as (
    select
          similarity_band_id
        , min_similarity
        , max_similarity
    from {{ ref('dim_similarity_bands') }}
),

ranked as (
    select
          dupe_perfume_id
        , original_perfume_id
        , shared_accords
        , similarity
        , row_number() over(partition by dupe_perfume_id order by similarity desc, original_perfume_id) 
            as similarity_rank
    from similarity
    qualify similarity_rank <= {{ var('dupe_candidates') }}
),

joined as(
    select
          r.dupe_perfume_id
        , r.original_perfume_id
        , r.similarity_rank
        , round(r.similarity, 4)                              as similarity
        , b.similarity_band_id
        , r.shared_accords
        , pd.gender = po.gender                               as same_gender

        -- medidas del dupe y del original
        , sd.bayesian_rating                                  as dupe_bayesian_rating
        , so.bayesian_rating                                  as original_bayesian_rating
        , sd.longevity_avg                                    as dupe_longevity_avg
        , so.longevity_avg                                    as original_longevity_avg
        , sd.sillage_avg                                      as dupe_sillage_avg
        , so.sillage_avg                                      as original_sillage_avg
        , sd.price_value_avg                                  as dupe_price_value_avg
        , so.price_value_avg                                  as original_price_value_avg

        -- diferencias (dupe - original): negativo = el dupe sale peor
        , sd.bayesian_rating - so.bayesian_rating             as bayesian_rating_diff
        , sd.longevity_avg   - so.longevity_avg               as longevity_diff
        , sd.sillage_avg     - so.sillage_avg                 as sillage_diff
        , sd.price_value_avg - so.price_value_avg             as price_value_diff

    from ranked r
    inner join perfumes pd on pd.perfume_id = r.dupe_perfume_id
    inner join perfumes po on po.perfume_id = r.original_perfume_id
    inner join scores sd on sd.perfume_id = r.dupe_perfume_id
    inner join scores so on so.perfume_id = r.original_perfume_id
    -- tramo de similitud: [min, max); el tramo superior no tiene máximo
    left join bands b
        on  r.similarity >= b.min_similarity
        and (r.similarity < b.max_similarity or b.max_similarity is null)
),

id_generated as(
    select
          {{ dbt_utils.generate_surrogate_key(['dupe_perfume_id', 'original_perfume_id']) }} as dupe_original_id
        , dupe_perfume_id
        , original_perfume_id
        , similarity_rank
        , similarity
        , similarity_band_id
        , shared_accords
        , same_gender
        , dupe_bayesian_rating
        , original_bayesian_rating
        , dupe_longevity_avg
        , original_longevity_avg
        , dupe_sillage_avg
        , original_sillage_avg
        , dupe_price_value_avg
        , original_price_value_avg
        , bayesian_rating_diff
        , longevity_diff
        , sillage_diff
        , price_value_diff

    from joined
)

select * from id_generated