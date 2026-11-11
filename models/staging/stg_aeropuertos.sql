with origen as (    
    select * from {{ source("raw_data","aeropuertos") }}
),

limpio as (              
    select 
        upper(trim(codigo_iata)) as codigo_iata,
        trim(nombre_aeropuerto) as nombre_aeropuerto,
        initcap(trim(ciudad)) as ciudad,
        initcap(trim(pais)) as pais,
        coalesce(trim(continente),'Desconocido') as continente
    from origen
),

deduplicado as(
    select
        *,
        row_number() over(partition by codigo_iata order by nombre_aeropuerto) as num_fila
    from limpio
)

select 
    codigo_iata,
    nombre_aeropuerto,
    ciudad,
    pais,
    continente
from deduplicado where  num_fila=1  