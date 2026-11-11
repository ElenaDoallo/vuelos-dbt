select
    matricula,
    codigo_compania,
    modelo,
    fabricante,
    capacidad
from {{ ref('stg_aviones') }}

union all

select
    'UNK'                as matricula,
    'UNK'                as codigo_compania,
    'Desconocido'        as modelo,
    'Desconocido'        as fabricante,
    cast(null as integer) as capacidad