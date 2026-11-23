with metrics as(
    select
          perfume_id
        , captured_at_utc
        , rating_avg                
        , rating_vote_count                
        , longevity_avg                      
        , sillage_avg                              
        , price_value_avg                      
        , have_count
        , had_count
        , want_count
        , perceived_female_votes
        , perceived_female_leaning_votes
        , perceived_unisex_votes
        , perceived_male_leaning_votes
        , perceived_male_votes
        , winter_votes
        , spring_votes
        , summer_votes
        , autumn_votes
        , day_votes
        , night_votes
        , popularity
        , compound_popularity
        , recent_popularity
        , last_comment_at_utc
    from {{ ref('stg_kaggle__perfumes') }}
),

cleaned as(
    select
          perfume_id
        , captured_at_utc
        , nullif(rating_avg, 0)         as rating_avg
        , rating_vote_count                
        , nullif(longevity_avg, 0)      as longevity_avg            
        , nullif(sillage_avg, 0)        as sillage_avg              
        , nullif(price_value_avg, 0)    as price_value_avg          
        , have_count
        , had_count
        , want_count
        , perceived_female_votes
        , perceived_female_leaning_votes
        , perceived_unisex_votes
        , perceived_male_leaning_votes
        , perceived_male_votes
        , winter_votes
        , spring_votes
        , summer_votes
        , autumn_votes
        , day_votes
        , night_votes
        , popularity
        , compound_popularity
        , recent_popularity
        , last_comment_at_utc
    from metrics
),

id_generated as(
    select
          {{ dbt_utils.generate_surrogate_key(['perfume_id', 'captured_at_utc']) }} as perfume_metrics_id
        , perfume_id
        , captured_at_utc
        , rating_avg
        , rating_vote_count                
        , longevity_avg            
        , sillage_avg               
        , price_value_avg           
        , have_count
        , had_count
        , want_count
        , perceived_female_votes
        , perceived_female_leaning_votes
        , perceived_unisex_votes
        , perceived_male_leaning_votes
        , perceived_male_votes
        , winter_votes
        , spring_votes
        , summer_votes
        , autumn_votes
        , day_votes
        , night_votes
        , popularity
        , compound_popularity
        , recent_popularity
        , last_comment_at_utc
    from cleaned
)

select * from id_generated