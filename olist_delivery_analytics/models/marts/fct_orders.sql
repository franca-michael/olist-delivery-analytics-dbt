with

orders as (

    select * from {{ ref('stg_olist__orders') }}

),

customers as (

    select * from {{ ref('stg_olist__customers') }}

),

order_items as (

    select * from {{ ref('int_order_items__aggregated_to_order') }}

),

payments as (

    select * from {{ ref('int_payments__aggregated_to_order') }}

),

reviews as (

    select * from {{ ref('int_reviews__latest_per_order') }}

),

final as (

    select
        orders.order_id,
        customers.customer_unique_id,
        orders.order_status,

        -- endereço do cliente NESTE pedido (customer_id é por pedido): é o local de entrega
        customers.customer_zip_code_prefix      as delivery_zip_code_prefix,
        customers.customer_city                 as delivery_city,
        customers.customer_state                as delivery_state,

        orders.purchased_at,
        cast(orders.purchased_at as date)       as purchase_date,
        orders.approved_at,
        orders.shipped_at,
        orders.delivered_at,
        orders.estimated_delivery_at,

        -- pedido sem item ou sem pagamento existe na origem: vira 0, não nulo
        coalesce(order_items.items_count, 0)    as items_count,
        coalesce(order_items.sellers_count, 0)  as sellers_count,
        coalesce(order_items.items_value, 0)    as items_value,
        coalesce(order_items.freight_value, 0)  as freight_value,
        coalesce(payments.payment_value, 0)     as payment_value,

        -- sem avaliação continua nulo: 0 seria uma nota
        reviews.review_score

    -- sempre a partir do grão do fato (pedido), com left join, para não perder pedidos
    from orders
    left join customers
        on orders.customer_id = customers.customer_id
    left join order_items
        on orders.order_id = order_items.order_id
    left join payments
        on orders.order_id = payments.order_id
    left join reviews
        on orders.order_id = reviews.order_id

)

select * from final