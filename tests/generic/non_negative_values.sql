{% test non_negative_values(model, column_name) %}

{% for col in column_name %}

select 
      '{{ col }}'   as column_name
    , {{ col }}     as value
from {{ model }}
where {{ col }} < 0

{% if not loop.last %}union all{% endif %}

{% endfor %}

{% endtest %}