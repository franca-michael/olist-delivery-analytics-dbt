with

source as (

    select * from {{ source('olist', 'order_items') }}

),

renamed as (

    select
        {{ dbt_utils.generate_surrogate_key(['order_id', 'order_item_id']) }} as order_item_sk,
        order_id,
        cast(order_item_id as integer)                as order_item_id,
        product_id,
        seller_id,
        cast(shipping_limit_date as timestamp)        as shipping_limit_at,
        cast(price as numeric(10, 2))                 as price,
        cast(freight_value as numeric(10, 2))         as freight_value

    from source

)

select * from renamed