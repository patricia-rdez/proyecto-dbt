----------------------------
-- Casteo de las columnas --
----------------------------

with source as(
    select
        *
    from {{ source('kaggle','perfumes') }}
),

casted as(
      try_to_number(id)
    , trim(slug)
    , trim(name)
    , trim(brand)
    , try_to_number(year)::number(4,0)
    , nullif(trim(collection),'')
    , trim(gender)
    , lower(trim(url))
    , try_to_number(rating_avg)::number(5,4)
    , try_to_number(vote_count)
    , try_to_number(rating_b1)
    , try_to_number(rating_b2)
    , try_to_number(rating_b3)
    , try_to_number(rating_b4)
    , try_to_number(rating_b5)
    , try_to_number(longevity_avg)::number(5,4)
    , try_to_number(longevity_b1)
    , try_to_number(longevity_b2)
    , try_to_number(longevity_b3)
    , try_to_number(longevity_b4)
    , try_to_number(longevity_b5)
    , try_to_number(sillage_avg)::number(5,4)
    , try_to_number(sillage_b1)
    , try_to_number(sillage_b2)
    , try_to_number(sillage_b3)
    , try_to_number(sillage_b4)
    , try_to_number(price_value_avg)::number(5,4)
    , try_to_number(price_value_b1)
    , try_to_number(price_value_b2)
    , try_to_number(price_value_b3)
    , try_to_number(price_value_b4)
    , try_to_number(price_value_b5)
    , try_to_number(have)
    , try_to_number(had)
    , try_to_number(want)
    , try_to_number(perceived_female)
    , try_to_number(perceived_female_leaning)
    , try_to_number(perceived_unisex)
    , try_to_number(perceived_male_leaning)
    , try_to_number(perceived_male)
    , try_to_number(winter)
    , try_to_number(spring)
    , try_to_number(summer)
    , try_to_number(autumn)
    , try_to_number(day)
    , try_to_number(night)
    , try_to_number(people)
    , try_to_number(magnitude)
    , try_to_number(compound_magnitude)
    , try_to_number(recent_magnitude)
    , to_timestamp_ntz(try_to_number(last_comment_at))
    , to_timestamp_ntz(try_to_number(scraped_at))
    , nullif(trim(accords), '')
    , nullif(trim(notes_top), '')
    , nullif(trim(notes_middle), '')
    , nullif(trim(notes_base), '')
    , nullif(trim(notes_flat), '')
    , nullif(trim(perfumers), '')
    , trim(description)
    , _loaded_at
),

renamed as(
      id                        as perfume_id
    , slug                      
    , name                      as perfume_name
    , brand                     as brand_name
    , year                      as release_year
    , collection                as collection_name
    , gender                    
    , url                       as
    , rating_avg                as
    , vote_count                as rating_vote_count
    , rating_b1                 as
    , rating_b2                 as
    , rating_b3                 as
    , rating_b4                 as
    , rating_b5                 as
    , longevity_avg             as
    , longevity_b1              as
    , longevity_b2              as
    , longevity_b3              as
    , longevity_b4              as
    , longevity_b5              as
    , sillage_avg               as
    , sillage_b1                as
    , sillage_b2                as
    , sillage_b3                as
    , sillage_b4                as
    , price_value_avg           as
    , price_value_b1            as
    , price_value_b2            as
    , price_value_b3            as
    , price_value_b4            as
    , price_value_b5            as
    , have                      as have_count
    , had                       as had_count
    , want                      as want_count
    , perceived_female          as perceived_female_votes
    , perceived_female_leaning  as perceived_female_leaning_votes
    , perceived_unisex          as perceived_unisex_votes
    , perceived_male_leaning    as perceived_male_leaning_votes
    , perceived_male            as perceived_male_votes
    , winter                    as
    , spring                    as
    , summer                    as
    , autumn                    as
    , day                       as
    , night                     as
    , people                    as
    , magnitude                 as
    , compound_magnitude        as
    , recent_magnitude          as
    , last_comment_at           as
    , scraped_at                as
    , accords                   as
    , notes_top                 as
    , notes_middle              as
    , notes_base                as
    , notes_flat                as
    , perfumers                 as
    , description               as
    , _loaded_at                as
)