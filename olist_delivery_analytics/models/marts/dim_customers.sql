with

customers as (

    select * from {{ ref('stg_olist__customers') }}

),

orders as (

    select * from {{ ref('stg_olist__orders') }}

),

customer_orders as (

    -- um customer_id por pedido: o join traz a data de cada pedido do cliente real
    select
        customers.customer_unique_id,
        customers.customer_zip_code_prefix,
        customers.customer_city,
        customers.customer_state,
        orders.order_id,
        orders.purchased_at

    from customers
    inner join orders
        on customers.customer_id = orders.customer_id

),

latest_location as (

    -- o mesmo cliente pode comprar de cidades diferentes; vale o endereço do pedido mais recente
    select
        customer_unique_id,
        customer_zip_code_prefix,
        customer_city,
        customer_state,
        row_number() over (
            partition by customer_unique_id
            order by purchased_at desc, order_id
        ) as location_rank

    from customer_orders

),

order_summary as (

    select
        customer_unique_id,
        min(purchased_at)           as first_order_at,
        max(purchased_at)           as last_order_at,
        count(distinct order_id)    as orders_count

    from customer_orders
    group by customer_unique_id

),

final as (

    select
        order_summary.customer_unique_id,
        latest_location.customer_zip_code_prefix,
        latest_location.customer_city,
        latest_location.customer_state,
        order_summary.first_order_at,
        order_summary.last_order_at,
        order_summary.orders_count

    from order_summary
    inner join latest_location
        on order_summary.customer_unique_id = latest_location.customer_unique_id
        and latest_location.location_rank = 1

)

select * from final