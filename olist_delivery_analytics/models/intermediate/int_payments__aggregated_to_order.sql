-- muda o grão: de pagamento para pedido
with

payments as (

    select * from {{ ref('stg_olist__payments') }}

),

aggregated as (

    select
        order_id,
        count(*)                        as payments_count,
        count(distinct payment_type)    as payment_types_count,
        sum(payment_value)              as payment_value

    from payments
    group by order_id

)

select * from aggregated