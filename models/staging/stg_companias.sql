with origen as (
    select * from {{ source('raw_data', 'companias') }}
),

limpio as (
    select
        upper(trim(codigo_compania))  as codigo_compania,
        trim(nombre_compania)         as nombre_compania,
        initcap(trim(pais))           as pais,
        case lower(replace(trim(tipo), '-', ' '))
            when 'red'      then 'Red'
            when 'low cost' then 'Low cost'
            when 'regional' then 'Regional'
            else trim(tipo)
        end                           as tipo_compania
    from origen
)

select * from limpio