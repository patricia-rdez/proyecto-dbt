with genders as(
    select
        gender_name
    from {{ ref("stg_kaggle__perfumes") }}
    where gender_name is not null
),

cleaned as(
    select distinct
          lower(gender_name) as gender_name
    from genders
),

id_generated as(
    select
          {{ dbt_utils.generate_surrogate_key(['gender_name']) }} as gender_id
        , gender_name  
    from cleaned
)

select * from id_generated
