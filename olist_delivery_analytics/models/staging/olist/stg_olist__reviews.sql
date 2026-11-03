with

source as (

    select * from {{ source('olist', 'reviews') }}

),

renamed as (

    select
        -- review_id NÃO é único na origem: a mesma avaliação aparece em mais de um pedido
        {{ dbt_utils.generate_surrogate_key(['review_id', 'order_id']) }} as review_sk,
        review_id,
        order_id,
        cast(review_score as integer)               as review_score,
        review_comment_title,
        review_comment_message,
        cast(review_creation_date as timestamp)     as review_created_at,
        cast(review_answer_timestamp as timestamp)  as review_answered_at

    from source

)

select * from renamed