with dias as (
    {{ dbt_utils.date_spine(
        datepart = "day",
        start_date = "cast('2025-01-01' as date)",
        end_date = "cast('2027-01-01' as date)"
    ) }}
),

calendario as (
    select
        cast(date_day as date)                      as fecha,
        extract(year from date_day)                 as anio,
        extract(quarter from date_day)              as trimestre,
        extract(month from date_day)                as mes,
        to_char(date_day, 'YYYY-MM')                as anio_mes,
        extract(year from date_day) * 100
            + extract(month from date_day)          as anio_mes_num,
        extract(dow from date_day)                  as dia_semana_dow
    from dias
)

select
    fecha,
    anio,
    trimestre,
    'T' || trimestre                                as nombre_trimestre,
    mes,
    case mes
        when 1  then 'Enero'      when 2  then 'Febrero'   when 3  then 'Marzo'
        when 4  then 'Abril'      when 5  then 'Mayo'      when 6  then 'Junio'
        when 7  then 'Julio'      when 8  then 'Agosto'    when 9  then 'Septiembre'
        when 10 then 'Octubre'    when 11 then 'Noviembre' when 12 then 'Diciembre'
    end                                             as nombre_mes,
    anio_mes,
    anio_mes_num,
    case when dia_semana_dow = 0 then 7 else dia_semana_dow end as dia_semana_num,
    case dia_semana_dow
        when 1 then 'Lunes'   when 2 then 'Martes'  when 3 then 'Miércoles'
        when 4 then 'Jueves'  when 5 then 'Viernes' when 6 then 'Sábado'
        when 0 then 'Domingo'
    end                                             as nombre_dia,
    case when dia_semana_dow in (0, 6) then 1 else 0 end as es_fin_de_semana,
    case when mes in (6, 7, 8, 9) then 'Alta' else 'Baja' end as temporada
from calendario