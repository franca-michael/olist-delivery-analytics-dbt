with

order_items as (

    select * from {{ ref('stg_olist__order_items') }}

),

orders as (

    select * from {{ ref('stg_olist__orders') }}

),

final as (

    select
        order_items.order_item_sk,
        order_items.order_id,
        order_items.order_item_id,
        order_items.product_id,
        order_items.seller_id,
        cast(orders.purchased_at as date)   as purchase_date,
        order_items.shipping_limit_at,
        order_items.price,
        order_items.freight_value

    from order_items
    left join orders
        on order_items.order_id = orders.order_id

)

select * from final