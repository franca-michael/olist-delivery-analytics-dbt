-- OTIF é do pedido, mas o pedido pode ter itens de vários vendedores:
-- cada vendedor responde pelo pedido inteiro, contado uma vez por vendedor
with

order_items as (

    select * from {{ ref('fct_order_items') }}

),

delivery as (

    select * from {{ ref('int_orders__delivery_status') }}
    where is_finalized

),

seller_orders as (

    -- distinct: um pedido conta uma vez por vendedor, não uma vez por item
    select distinct
        order_items.seller_id,
        delivery.order_id,
        cast({{ dbt.date_trunc('month', 'delivery.estimated_delivery_at') }} as date) as reference_month,
        delivery.is_on_time,
        delivery.is_in_full,
        delivery.is_otif

    from order_items
    inner join delivery
        on order_items.order_id = delivery.order_id

),

final as (

    select
        seller_id,
        reference_month,
        count(*)                                        as orders_finalized,
        sum(case when is_on_time then 1 else 0 end)     as orders_on_time,
        sum(case when is_in_full then 1 else 0 end)     as orders_in_full,
        sum(case when is_otif then 1 else 0 end)        as orders_otif,
        round(
            100.0 * sum(case when is_otif then 1 else 0 end) / count(*),
            2
        )                                               as otif_pct

    from seller_orders
    group by seller_id, reference_month

)

select * from final