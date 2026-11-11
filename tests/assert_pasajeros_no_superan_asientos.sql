select
    id_vuelo,
    pasajeros,
    asientos_ofertados
from {{ ref('int_vuelos_enriquecidos') }}
where pasajeros > asientos_ofertados