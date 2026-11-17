-- conferência do OTIF geral, no grão do pedido (sem a quebra por vendedor)
select
    cast(extract(year from estimated_delivery_at) as integer)        as reference_year,
    count(*)                                                         as orders_finalized,
    round(100.0 * avg(case when is_on_time then 1 else 0 end), 1)   as on_time_pct,
    round(100.0 * avg(case when is_in_full then 1 else 0 end), 1)   as in_full_pct,
    round(100.0 * avg(case when is_otif then 1 else 0 end), 1)      as otif_pct,
    round(avg(delivery_delay_days), 1)                               as avg_delay_days

from {{ ref('int_orders__delivery_status') }}
where is_finalized
group by 1
order by 1