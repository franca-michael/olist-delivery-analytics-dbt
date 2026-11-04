with

order_items as (

    select * from {{ ref('stg_olist__order_items') }}

),

aggregated as (

    select
        order_id,
        count(*)                    as items_count,
        count(distinct seller_id)   as sellers_count,
        sum(price)                  as items_value,
        sum(freight_value)          as freight_value

    from order_items
    group by order_id

)

select * from aggregated