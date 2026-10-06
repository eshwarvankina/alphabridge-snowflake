with snapshot as (

    select * from {{ ref('security_master_snapshot') }}

),

final as (

    select
        dbt_scd_id               as security_version_id,
        ticker,
        isin,
        cusip,
        company_name,
        sector,
        industry,
        exchange_code,
        exchange_name,
        currency,
        dbt_valid_from           as valid_from,
        dbt_valid_to             as valid_to,
        dbt_valid_to is null     as is_current
    from snapshot

)

select * from final