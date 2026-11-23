{#
    Calcula la media de las métricas rating, longevity, sillage y price_value a partir de los votos.
#}

{% macro avg_from_votes (metric, values) -%}

    (
        {% for i in range(1, values + 1) %}
            {{ i }} * {{ metric }}_b{{ i }}{% if not loop.last %} +{% endif %}
        {% endfor %}
    )
    /
    nullif(
        {% for i in range(1, values + 1) %}
            {{ metric }}_b{{ i }}{% if not loop.last %} +{% endif %}
        {% endfor %}
    , 0)

{%- endmacro %}