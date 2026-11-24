{{
    config(
        materialized='incremental',
        unique_key='perfume_metrics_id',
        incremental_strategy='merge',
        on_schema_change='fail'
    )
}}

with metrics as(
    select
          perfume_id
        , captured_at_utc
        , rating_avg
        , rating_b1                 
        , rating_b2                 
        , rating_b3                 
        , rating_b4                 
        , rating_b5                
        , rating_vote_count                
        , longevity_avg
        , longevity_b1              
        , longevity_b2             
        , longevity_b3             
        , longevity_b4            
        , longevity_b5                      
        , sillage_avg
        , sillage_b1                
        , sillage_b2                
        , sillage_b3                
        , sillage_b4                              
        , price_value_avg
        , price_value_b1            
        , price_value_b2            
        , price_value_b3            
        , price_value_b4            
        , price_value_b5                     
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
        , date_load
    from {{ ref('stg_kaggle__perfumes') }}

    {% if is_incremental() %}
    -- solo las cargas de bronze posteriores a la última ya procesada
    where date_load > (select max(date_load) from {{ this }})
    {% endif %}
),

cleaned as(
    select
          perfume_id
        , captured_at_utc
        , round(coalesce(nullif(rating_avg, 0), {{ avg_from_votes('rating', 5) }}), 4)            as rating_avg
        , rating_vote_count                
        , round(coalesce(nullif(longevity_avg, 0), {{ avg_from_votes('longevity', 5) }}), 4)      as longevity_avg            
        , round(coalesce(nullif(sillage_avg, 0), {{ avg_from_votes('sillage', 4) }}), 4)          as sillage_avg              
        , round(coalesce(nullif(price_value_avg, 0), {{ avg_from_votes('price_value', 5) }}), 4)  as price_value_avg         
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
        , date_load
    from metrics
    qualify row_number() over (partition by perfume_id, captured_at_utc order by date_load desc) = 1
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
        , date_load
    from cleaned
)

select * from id_generated