with vuelos as (
    select * from {{ ref('int_vuelos_horarios') }}
),

aviones as (
    select * from {{ ref('stg_aviones') }}
),

aeropuertos as (
    select * from {{ ref('stg_aeropuertos') }}
),

unidos as (
    select
        v.*,
        av.capacidad as capacidad_avion,
        case when ao.codigo_iata is null then 'UNK' else v.codigo_origen  end as codigo_origen_final,
        case when ad.codigo_iata is null then 'UNK' else v.codigo_destino end as codigo_destino_final,
        case when av.matricula   is null then 'UNK' else v.matricula      end as matricula_final
    from vuelos v
    left join aviones     av on v.matricula      = av.matricula
    left join aeropuertos ao on v.codigo_origen  = ao.codigo_iata
    left join aeropuertos ad on v.codigo_destino = ad.codigo_iata
),

imputados as (
    select
        *,
        coalesce(
            asientos_ofertados,
            capacidad_avion,
            max(asientos_ofertados) over (partition by matricula)
        ) as asientos_imputados,
        coalesce(
            distancia_km,
            max(distancia_km) over (partition by codigo_origen, codigo_destino)
        ) as distancia_imputada
    from unidos
)

select
    id_vuelo,
    numero_vuelo,
    fecha_vuelo,
    codigo_origen_final  as codigo_origen,
    codigo_destino_final as codigo_destino,
    codigo_compania,
    matricula_final      as matricula,
    estado,
    salida_prog_ts,
    llegada_prog_ts,
    salida_real_ts,
    llegada_real_ts,
    pasajeros,
    case
        when asientos_imputados > capacidad_avion then capacidad_avion
        else asientos_imputados
    end                                                   as asientos_ofertados,
    distancia_imputada                                    as distancia_km,
    retraso_salida_min,
    retraso_llegada_min,

    case when estado = 'Cancelado' then 1 else 0 end      as es_cancelado,
    case when estado = 'Desviado'  then 1 else 0 end      as es_desviado,
    case
        when estado = 'Aterrizado' and retraso_llegada_min <= 15 then 1
        when estado = 'Aterrizado' then 0
    end                                                   as es_puntual_15,

    case when asientos_ofertados is null then 1 else 0 end as asientos_imputados_flag,
    case when codigo_origen = codigo_destino then 1 else 0 end as ruta_incoherente_flag
from imputados