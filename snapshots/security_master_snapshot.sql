{% snapshot security_master_snapshot %}

{{
    config(
        target_schema = 'CURATED',
        unique_key    = 'ticker',
        strategy      = 'check',
        check_cols    = ['isin', 'cusip', 'company_name', 'sector',
                         'industry', 'exchange_name', 'currency']
    )
}}

with latest_load as (

    select *
    from {{ ref('stg_security_master') }}
    where reject_reason is null
    qualify row_number() over (
        partition by ticker
        order by file_last_modified desc, loaded_at desc
    ) = 1

)

select
    ticker,
    isin,
    cusip,
    company_name,
    sector,
    industry,
    exchange_code,
    exchange_name,
    currency,
    source_file
from latest_load

{% endsnapshot %}