with

products as (

    select * from {{ ref('stg_olist__products') }}

),

translation as (

    select * from {{ ref('stg_olist__category_translation') }}

),

final as (

    select
        products.product_id,
        products.product_category_name,
        -- nem toda categoria tem tradução na origem: cai para o nome em português
        coalesce(
            translation.product_category_name_english,
            products.product_category_name
        )                                   as product_category_name_english,
        products.product_weight_g,
        products.product_length_cm,
        products.product_height_cm,
        products.product_width_cm,
        products.product_photos_qty

    from products
    left join translation
        on products.product_category_name = translation.product_category_name

)

select * from final