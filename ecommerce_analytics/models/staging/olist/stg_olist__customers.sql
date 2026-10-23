with

source as (

    select * from {{ source('olist', 'customers') }}

),

renamed as (

    select
        customer_id,
        customer_unique_id,
        -- a ingestão leu o CEP como número e perdeu o zero à esquerda (01037 virou 1037)
        lpad(cast(customer_zip_code_prefix as {{ dbt.type_string() }}), 5, '0') as customer_zip_code_prefix,
        customer_city,
        upper(customer_state)                                                 as customer_state

    from source

)

select * from renamed