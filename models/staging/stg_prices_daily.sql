with source as (
    select *
    from {{source('raw', 'prices_daily')}}
),

typed as (
        select
        upper(trim(ticker))                           as ticker,
        try_to_date(trim(trade_date), 'YYYY-MM-DD')   as trade_date,
        try_to_decimal(trim(open), 18, 6)             as open_price,
        try_to_decimal(trim(high), 18, 6)             as high_price,
        try_to_decimal(trim(low), 18, 6)              as low_price,
        try_to_decimal(trim(close), 18, 6)            as close_price,
        try_to_decimal(trim(adj_close), 18, 6)        as adj_close_price,
        try_to_number(trim(volume))                   as volume,
        _source_file                                  as source_file,
        _file_row_number                              as file_row_number,
        _file_last_modified                           as file_last_modified,
        _loaded_at                                    as loaded_at
    from source

), final as 
(
select *,
    case 
        when ticker is null or ticker = '' then 'missing ticker'
        when trade_date is null then 'invalid trade_date'
        when close_price is null then 'invalid close'
        when adj_close_price is null then 'invalid adj_close'
    end as reject_reason
from typed
)

select *
from final
