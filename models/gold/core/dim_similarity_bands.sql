with bands as(
    select
          similarity_band_id
        , band_name
        , min_similarity
        , max_similarity
        , sort_order
    from {{ ref('similarity_bands') }}
)

select * from bands