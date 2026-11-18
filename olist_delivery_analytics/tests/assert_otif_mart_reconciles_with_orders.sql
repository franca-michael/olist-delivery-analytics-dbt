-- reconciliação: o total de pedidos do mart tem que bater com os pares
-- (vendedor, pedido) finalizados contados direto na fonte. Pega contagem por item no lugar de pedido
with

mart as (

    select sum(orders_finalized) as total_orders
    from {{ ref('mart_otif_by_seller_month') }}

),

source_pairs as (

    select count(*) as total_orders
    from (
        select distinct
            order_items.seller_id,
            order_items.order_id
        from {{ ref('fct_order_items') }} as order_items
        inner join {{ ref('int_orders__delivery_status') }} as delivery
            on order_items.order_id = delivery.order_id
        where delivery.is_finalized
    ) as pairs

)

select
    mart.total_orders         as mart_total,
    source_pairs.total_orders as source_total

from mart
cross join source_pairs
where mart.total_orders <> source_pairs.total_orders