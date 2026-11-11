select
    id_vuelo,
    retraso_llegada_min,
    retraso_llegada_calculado_min
from {{ ref('int_vuelos_horarios') }}
where retraso_llegada_min <> retraso_llegada_calculado_min