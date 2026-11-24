with source as(
    select
        *
    from {{ source('kaggle','perfumes') }}
),

casted as(
    select
          try_to_number(id)                                     as id
        , trim(slug)                                            as slug
        , trim(name)                                            as name
        , trim(brand)                                           as brand
        , try_to_number(year,4,0)                               as year
        , nullif(trim(collection),'')                           as collection
        , trim(gender)                                          as gender
        , lower(trim(url))                                      as url
        , try_to_number(rating_avg,5,4)                         as rating_avg
        , try_to_number(vote_count)                             as vote_count
        , try_to_number(rating_b1)                              as rating_b1
        , try_to_number(rating_b2)                              as rating_b2
        , try_to_number(rating_b3)                              as rating_b3
        , try_to_number(rating_b4)                              as rating_b4
        , try_to_number(rating_b5)                              as rating_b5
        , try_to_number(longevity_avg,5,4)                      as longevity_avg
        , try_to_number(longevity_b1)                           as longevity_b1
        , try_to_number(longevity_b2)                           as longevity_b2
        , try_to_number(longevity_b3)                           as longevity_b3
        , try_to_number(longevity_b4)                           as longevity_b4
        , try_to_number(longevity_b5)                           as longevity_b5
        , try_to_number(sillage_avg,5,4)                        as sillage_avg
        , try_to_number(sillage_b1)                             as sillage_b1
        , try_to_number(sillage_b2)                             as sillage_b2
        , try_to_number(sillage_b3)                             as sillage_b3
        , try_to_number(sillage_b4)                             as sillage_b4
        , try_to_number(price_value_avg,5,4)                    as price_value_avg
        , try_to_number(price_value_b1)                         as price_value_b1
        , try_to_number(price_value_b2)                         as price_value_b2
        , try_to_number(price_value_b3)                         as price_value_b3
        , try_to_number(price_value_b4)                         as price_value_b4
        , try_to_number(price_value_b5)                         as price_value_b5
        , try_to_number(have)                                   as have
        , try_to_number(had)                                    as had
        , try_to_number(want)                                   as want
        , try_to_number(perceived_female)                       as perceived_female
        , try_to_number(perceived_female_leaning)               as perceived_female_leaning
        , try_to_number(perceived_unisex)                       as perceived_unisex
        , try_to_number(perceived_male_leaning)                 as perceived_male_leaning
        , try_to_number(perceived_male)                         as perceived_male
        , try_to_number(winter)                                 as winter
        , try_to_number(spring)                                 as spring
        , try_to_number(summer)                                 as summer
        , try_to_number(autumn)                                 as autumn
        , try_to_number(day)                                    as day
        , try_to_number(night)                                  as night
        , try_to_number(people)                                 as people
        , try_to_number(magnitude)                              as magnitude
        , try_to_number(compound_magnitude)                     as compound_magnitude
        , try_to_number(recent_magnitude)                       as recent_magnitude
        , to_timestamp_ntz(try_to_number(last_comment_at))      as last_comment_at
        , to_timestamp_ntz(try_to_number(scraped_at))           as scraped_at
        , nullif(trim(accords), '')                             as accords
        , nullif(trim(notes_top), '')                           as notes_top
        , nullif(trim(notes_middle), '')                        as notes_middle
        , nullif(trim(notes_base), '')                          as notes_base
        , nullif(trim(notes_flat), '')                          as notes_flat
        , nullif(trim(perfumers), '')                           as perfumers
        , nullif(trim(description), '')                         as description
        , _loaded_at
    from source
),

renamed as(
    select
          id                        as perfume_id
        , slug                      
        , name                      as perfume_name
        , brand                     as brand_name
        , year                      as release_year
        , collection                as collection_name
        , gender
        , url                       
        , rating_avg                
        , vote_count                as rating_vote_count
        , rating_b1                 
        , rating_b2                 
        , rating_b3                 
        , rating_b4                 
        , rating_b5                 
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
        , have                      as have_count
        , had                       as had_count
        , want                      as want_count
        , perceived_female          as perceived_female_votes
        , perceived_female_leaning  as perceived_female_leaning_votes
        , perceived_unisex          as perceived_unisex_votes
        , perceived_male_leaning    as perceived_male_leaning_votes
        , perceived_male            as perceived_male_votes
        , winter                    as winter_votes
        , spring                    as spring_votes
        , summer                    as summer_votes
        , autumn                    as autumn_votes
        , day                       as day_votes
        , night                     as night_votes
        , people                    as people_count
        , magnitude                 as popularity
        , compound_magnitude        as compound_popularity
        , recent_magnitude          as recent_popularity
        , last_comment_at           as last_comment_at_utc
        , scraped_at                as captured_at_utc
        , accords                   
        , notes_top                 
        , notes_middle              
        , notes_base                
        , notes_flat                
        , perfumers                 
        , description               
        , _loaded_at                as date_load
    from casted              
)

select * from renamed