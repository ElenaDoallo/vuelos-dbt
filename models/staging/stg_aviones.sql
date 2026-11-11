with origen as (
    select * from {{ source('raw_data', 'aviones') }}
),

limpio as (
    select
        upper(trim(matricula))                      as matricula,
        upper(trim(codigo_compania))                as codigo_compania,
        replace(trim(modelo), ' neo', 'neo')        as modelo,
        case upper(trim(fabricante))
            when 'AIRBUS'     then 'Airbus'
            when 'BOEING'     then 'Boeing'
            when 'ATR'        then 'ATR'
            when 'BOMBARDIER' then 'Bombardier'
            else trim(fabricante)
        end                                         as fabricante,
        cast(nullif(trim(capacidad), '') as integer) as capacidad
    from origen
)

select * from limpio