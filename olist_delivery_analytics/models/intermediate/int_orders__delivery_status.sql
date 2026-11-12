-- regra de OTIF no grão do pedido: uma flag por conceito, cada uma com a sua decisão de negócio
with

orders as (

    select * from {{ ref('stg_olist__orders') }}

),

flags as (

    select
        order_id,
        order_status,
        purchased_at,
        delivered_at,
        estimated_delivery_at,

        -- finalizado: o pedido já tem desfecho. Em trânsito fica fora do denominador
        order_status in ('delivered', 'canceled', 'unavailable')         as is_finalized,

        -- in full (proxy): entregue de fato. A Olist não tem quantidade pedida x entregue
        order_status = 'delivered' and delivered_at is not null           as is_in_full,

        -- on time: entregue até o fim do dia prometido. Sem entrega, não está no prazo
        coalesce(
            cast(delivered_at as date) <= cast(estimated_delivery_at as date),
            false
        )                                                                 as is_on_time,

        -- positivo = dias de atraso; negativo = chegou antes da promessa
        {{ dbt.datediff('estimated_delivery_at', 'delivered_at', 'day') }} as delivery_delay_days

    from orders

),

final as (

    select
        *,
        is_on_time and is_in_full                                         as is_otif

    from flags

)

select * from final