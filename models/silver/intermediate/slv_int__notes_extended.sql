with source as(
    select
          perfume_id
        , notes_top
        , notes_middle
        , notes_base
        , notes_flat
    from {{ ref('stg_kaggle__perfumes') }}
),

extended as(
    {{ list_to_name_and_weight('notes_top','top') }}
    union all
    {{ list_to_name_and_weight('notes_middle','middle') }}
    union all
    {{ list_to_name_and_weight('notes_base','base') }}
    union all
    {{ list_to_name_and_weight('notes_flat','flat') }}
)

select
      perfume_id
    , level
    , item_name      as note_name
    , item_value     as weight
    , position
from extended