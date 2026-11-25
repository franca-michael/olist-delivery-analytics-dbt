-- teste singular: devolve as linhas que quebram a regra. Zero linhas = passou
-- warn, e não error: dado público tem anomalias, e a decisão é registrar, não esconder
{{ config(severity = 'warn') }}

select
    order_id,
    order_status,
    purchased_at,
    delivered_at

from {{ ref('stg_olist__orders') }}
where delivered_at < purchased_at