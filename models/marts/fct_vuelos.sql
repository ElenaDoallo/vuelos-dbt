select
    -- Clave primaria (grano: un vuelo en una fecha)
    id_vuelo,

    -- Claves foráneas hacia las dimensiones
    fecha_vuelo,
    codigo_compania,
    codigo_origen,
    codigo_destino,
    matricula,

    -- Atributos descriptivos del propio vuelo
    numero_vuelo,
    codigo_origen || '-' || codigo_destino     as ruta,
    estado,
    salida_prog_ts,
    llegada_prog_ts,
    salida_real_ts,
    llegada_real_ts,

    -- Medidas
    pasajeros,
    asientos_ofertados,
    distancia_km,
    asientos_ofertados * distancia_km          as ask,
    pasajeros * distancia_km                   as rpk,
    retraso_salida_min,
    retraso_llegada_min,

    -- Indicadores para KPIs
    es_cancelado,
    es_desviado,
    es_puntual_15,

    -- Indicadores de calidad
    asientos_imputados_flag,
    ruta_incoherente_flag
from {{ ref('int_vuelos_enriquecidos') }}