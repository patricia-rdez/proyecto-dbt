{{
    config(
        severity='error',
        error_if='>0'
    )
}}

select
      perfume_id
    , rating_vote_count
    , people_count
from {{ ref('stg_kaggle__perfumes') }}
where coalesce(people_count, 0) != rating_vote_count