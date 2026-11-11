{{ config(severity = 'warn') }}

select
    id_vuelo,
    codigo_origen,
    codigo_destino
from {{ ref('stg_vuelos') }}
where codigo_origen = codigo_destino