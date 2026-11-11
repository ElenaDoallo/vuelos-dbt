select
    codigo_iata,
    nombre_aeropuerto,
    ciudad,
    pais,
    continente
from {{ ref('stg_aeropuertos') }}

union all

select
    'UNK'           as codigo_iata,
    'Desconocido'   as nombre_aeropuerto,
    'Desconocido'   as ciudad,
    'Desconocido'   as pais,
    'Desconocido'   as continente