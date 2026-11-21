{#
    Sirve para CTEs LLAMADAS SOURCE con columnas perfume_id y column_name, 
    donde las entradas de column_name son listas de la forma "nombre:valor|nombre:valor".
    La macro descompone la lista en filas.
    El argumento level se usa en el caso de las notas, para sus respectivos niveles
#}

{% macro list_to_name_and_weight(column_name, level=none) -%}
    
    select
          perfume_id
        {% if level is not none %}
        , '{{ level }}'                             as level
        {% endif %}
        , split_part(e.value, ':', 1)               as item_name
        , split_part(e.value, ':', 2)               as item_value
        , e.index                                   as position
    from source,
         lateral split_to_table(replace(source.{{ column_name }}, ' | ', ' / '), '|') as e
         -- CAMBIA SOLO LAS | RODEADAS DE ESPACIOS (LAS DE LA NOTA EUSTOMA | LISIANTHUS)

{%- endmacro %}