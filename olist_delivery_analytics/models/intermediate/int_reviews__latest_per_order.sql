-- um pedido pode ter mais de uma avaliação; fica a mais recente (a opinião final do cliente)
with

reviews as (

    select * from {{ ref('stg_olist__reviews') }}

),

ranked as (

    select
        order_id,
        review_id,
        review_score,
        review_created_at,
        row_number() over (
            partition by order_id
            order by review_created_at desc, review_answered_at desc, review_id
        ) as review_rank

    from reviews

),

latest as (

    select
        order_id,
        review_id,
        review_score,
        review_created_at

    from ranked
    where review_rank = 1

)

select * from latest