select
    codigo_compania,
    nombre_compania,
    pais          as pais_compania,
    tipo_compania
from {{ ref('stg_companias') }}