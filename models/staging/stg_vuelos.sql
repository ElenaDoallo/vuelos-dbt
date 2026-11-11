with origen as (
    select * from {{ source('raw_data', 'vuelos') }}
),

limpio as (
    select
        trim(id_vuelo)                                  as id_vuelo,
        upper(trim(numero_vuelo))                       as numero_vuelo,

        case
            when trim(fecha_vuelo) like '__/__/____' then to_date(trim(fecha_vuelo), 'DD/MM/YYYY')
            when trim(fecha_vuelo) like '____-__-__' then to_date(trim(fecha_vuelo), 'YYYY-MM-DD')
        end                                             as fecha_vuelo,

        cast(nullif(trim(hora_salida_prog), '') as time)  as hora_salida_prog,
        cast(nullif(trim(hora_salida_real), '') as time)  as hora_salida_real,
        cast(nullif(trim(hora_llegada_prog), '') as time) as hora_llegada_prog,
        cast(nullif(trim(hora_llegada_real), '') as time) as hora_llegada_real,

        upper(trim(origen))                             as codigo_origen,
        upper(trim(destino))                            as codigo_destino,
        upper(trim(codigo_compania))                    as codigo_compania,
        upper(trim(matricula_avion))                    as matricula,

        cast(nullif(trim(pasajeros), '') as integer)          as pasajeros,
        cast(nullif(trim(asientos_ofertados), '') as integer) as asientos_ofertados,
        cast(nullif(trim(distancia_km), '') as integer)       as distancia_km,

        case
            when upper(trim(estado)) in ('ATERRIZADO', 'LANDED')    then 'Aterrizado'
            when upper(trim(estado)) in ('CANCELADO', 'CANCELLED')  then 'Cancelado'
            when upper(trim(estado)) in ('DESVIADO', 'DIVERTED')    then 'Desviado'
        end                                             as estado_origen,

        {{ convertir_retraso_a_minutos('retraso_min') }} as retraso_llegada_min,

        cast(_cargado_en as timestamp)                  as cargado_en
    from origen
),

deduplicado as (
    select
        *,
        row_number() over (partition by id_vuelo order by cargado_en desc) as num_fila
    from limpio
    where id_vuelo is not null
),

reglas as (
    select
        id_vuelo,
        numero_vuelo,
        fecha_vuelo,
        hora_salida_prog,
        hora_salida_real,
        hora_llegada_prog,
        hora_llegada_real,
        codigo_origen,
        codigo_destino,
        codigo_compania,
        matricula,

        case
            when pasajeros < 0 then null
            when pasajeros > asientos_ofertados then null
            else pasajeros
        end                                             as pasajeros,

        asientos_ofertados,

        case when distancia_km > 0 then distancia_km end as distancia_km,

        case
            when hora_llegada_real is not null then 'Aterrizado'
            when estado_origen is not null     then estado_origen
            when hora_salida_real is not null  then 'Desviado'
            else 'Cancelado'
        end                                             as estado,

        retraso_llegada_min,
        cargado_en
    from deduplicado
    where num_fila = 1
      and fecha_vuelo is not null
)

select * from reglas