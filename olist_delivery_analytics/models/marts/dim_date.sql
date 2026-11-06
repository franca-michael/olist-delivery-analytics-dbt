-- calendário fixo que cobre todo o período do dataset (set/2016 a out/2018) com folga
with

date_spine as (

    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2016-01-01' as date)",
        end_date="cast('2019-01-01' as date)"
    ) }}

),

final as (

    select
        cast(date_day as date)                                  as date_day,
        cast(extract(year from date_day) as integer)            as year_number,
        cast(extract(quarter from date_day) as integer)         as quarter_number,
        cast(extract(month from date_day) as integer)           as month_number,
        cast({{ dbt.date_trunc('month', 'date_day') }} as date) as month_start_date,
        -- 0 = domingo ... 6 = sábado (padrão do Postgres; revisar no BigQuery, etapa 9)
        cast(extract(dow from date_day) as integer)             as day_of_week_number

    from date_spine

)

select * from final