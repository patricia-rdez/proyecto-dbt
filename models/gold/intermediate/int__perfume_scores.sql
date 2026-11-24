with latest as (
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
    from {{ ref('slv_kaggle__perfume_metrics') }}
    qualify row_number() over (partition by perfume_id order by captured_at_utc desc) = 1
),

global_avg as (
    select 
        avg(rating_avg) as global_rating_avg
    from latest
    where rating_avg is not null
),

scored as (
    select
          l.perfume_id
        , l.captured_at_utc
        , l.rating_avg
        , l.rating_vote_count
        , l.longevity_avg
        , l.sillage_avg
        , l.price_value_avg
        , l.have_count
        , l.had_count
        , l.want_count
        , l.popularity
        , l.recent_popularity
        , l.compound_popularity
        , case
              when l.rating_avg is not null then
                  (l.rating_vote_count * l.rating_avg
                   + {{ var('bayesian_min_votes') }} * g.global_rating_avg)
                  / (l.rating_vote_count + {{ var('bayesian_min_votes') }})
          end                                                         as bayesian_rating

        , l.winter_votes + l.spring_votes + l.summer_votes + l.autumn_votes as season_votes
        , l.winter_votes
        , l.spring_votes
        , l.summer_votes
        , l.autumn_votes
        , l.day_votes
        , l.night_votes

    from latest l
    cross join global_avg g
),

dominant as(
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
        , popularity
        , recent_popularity
        , compound_popularity
        , winter_votes / nullif(season_votes, 0)  as winter_share
        , spring_votes / nullif(season_votes, 0)  as spring_share
        , summer_votes / nullif(season_votes, 0)  as summer_share
        , autumn_votes / nullif(season_votes, 0)  as autumn_share

        , case
            when season_votes = 0 then null
            when winter_votes = greatest(winter_votes, spring_votes, summer_votes, autumn_votes) then 'winter'
            when spring_votes = greatest(winter_votes, spring_votes, summer_votes, autumn_votes) then 'spring'
            when summer_votes = greatest(winter_votes, spring_votes, summer_votes, autumn_votes) then 'summer'
            else 'autumn'
        end                                      as dominant_season

        , case
            when day_votes + night_votes = 0 then null
            when day_votes >= night_votes then 'day'
            else 'night'
        end                                      as dominant_daypart

    from scored
)

select * from dominant