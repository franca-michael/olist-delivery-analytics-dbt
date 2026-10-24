{{ config(materialized='table') }}

with customers as (
    -- macro ref() em vez de source(). 
    -- O ref() cria a dependência: o dbt sabe que fct_customer_orders depende de stg_customers.
    select * from {{ ref('stg_olist__customers') }}
),

orders as (
    select * from {{ ref('stg_olist__orders') }}
),

final as (
    select
        orders.order_id,
        customers.customer_unique_id,
        customers.customer_city as city,
        customers.customer_state as state,
        orders.order_status,
        orders.purchased_at,
        orders.delivered_at
    from orders
    left join customers on orders.customer_id = customers.customer_id
)

select * from final