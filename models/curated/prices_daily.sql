{{
    config(
        materialized = 'incremental',
        unique_key = ['ticker', 'trade_date'],
        incremental_strategy = 'merge',
        on_schema_change = 'fail'
    )
}}


with staged as (

    select *
    from {{ ref('stg_prices_daily') }}
    where reject_reason is null

    {% if is_incremental() %}
        and loaded_at > (select max(raw_loaded_at) from {{ this }})
    {% endif %}

), deduped as (

    select *
    from staged
    qualify row_number() over (
        partition by ticker, trade_date
        order by file_last_modified desc, loaded_at desc, file_row_number desc
    ) = 1

), final as (

    select
        ticker,
        trade_date,
        open_price,
        high_price,
        low_price,
        close_price,
        adj_close_price,
        volume,
        source_file,
        loaded_at           as raw_loaded_at,
        current_timestamp() as curated_at
    from deduped

)

select * from final