with vuelos as (
    select * from {{ ref('stg_vuelos') }}
),

programados as (
    select
        *,
        fecha_vuelo + hora_salida_prog as salida_prog_ts,
        case
            when hora_llegada_prog >= hora_salida_prog
                then fecha_vuelo + hora_llegada_prog
            else dateadd(day, 1, fecha_vuelo + hora_llegada_prog)
        end as llegada_prog_ts
    from vuelos
),

reales_candidatos as (
    select
        *,
        fecha_vuelo + hora_salida_real            as salida_real_candidata,
        trunc(llegada_prog_ts) + hora_llegada_real as llegada_real_candidata
    from programados
),

reales as (
    select
        *,
        case
            when salida_real_candidata is null then null
            when datediff(minute, salida_prog_ts, salida_real_candidata) < -60
                then dateadd(day, 1, salida_real_candidata)
            else salida_real_candidata
        end as salida_real_ts,

        case
            when llegada_real_candidata is null then null
            when datediff(minute, llegada_prog_ts, llegada_real_candidata) < -120
                then dateadd(day, 1, llegada_real_candidata)
            when datediff(minute, llegada_prog_ts, llegada_real_candidata) > 1200
                then dateadd(day, -1, llegada_real_candidata)
            else llegada_real_candidata
        end as llegada_real_ts
    from reales_candidatos
)

select
    id_vuelo,
    numero_vuelo,
    fecha_vuelo,
    codigo_origen,
    codigo_destino,
    codigo_compania,
    matricula,
    pasajeros,
    asientos_ofertados,
    distancia_km,
    estado,
    salida_prog_ts,
    llegada_prog_ts,
    salida_real_ts,
    llegada_real_ts,
    datediff(minute, salida_prog_ts, salida_real_ts)   as retraso_salida_min,
    retraso_llegada_min,
    datediff(minute, llegada_prog_ts, llegada_real_ts) as retraso_llegada_calculado_min,
    cargado_en
from reales