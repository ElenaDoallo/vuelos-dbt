{% macro convertir_retraso_a_minutos(columna) %}
    case
        when {{ columna }} is null
            then null
        when {{ columna }} like '%min%'
            then cast(trim(replace({{ columna }}, 'min', '')) as integer)
        when {{ columna }} like '%:%'
            then cast(split_part(trim({{ columna }}), ':', 1) as integer) * 60
               + cast(split_part(trim({{ columna }}), ':', 2) as integer)
        else cast(trim({{ columna }}) as integer)
    end
{% endmacro %}