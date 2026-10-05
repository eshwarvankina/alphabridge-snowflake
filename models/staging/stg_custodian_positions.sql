with source as (

    select * from {{ source('raw', 'custodian_positions') }}

),

typed as (

    select
        try_to_date(trim(as_of_dt), 'YYYYMMDD')      as position_date,
        upper(trim(acct_no))                         as account_id,
        upper(trim(fund_cd))                         as fund_code,
        upper(trim(isin))                            as isin,
        trim(sec_desc)                               as security_description,
        try_to_decimal(trim(settled_qty), 38, 4)     as quantity,
        try_to_decimal(trim(cust_price), 18, 6)      as custodian_price,
        try_to_decimal(trim(mkt_val_usd), 18, 2)     as custodian_market_value,
        upper(trim(ccy))                             as currency,
        _source_file                                 as source_file,
        _file_row_number                             as file_row_number,
        _file_last_modified                          as file_last_modified,
        _loaded_at                                   as loaded_at
    from source

),

final as (

    select
        *,
        case
            when position_date is null                  then 'invalid as_of_dt'
            when fund_code is null or fund_code = ''    then 'missing fund_code'
            when isin is null or length(isin) != 12     then 'invalid isin'
            when quantity is null                       then 'invalid quantity'
            when custodian_price is null                then 'invalid custodian_price'
        end as reject_reason
    from typed

)

select * from final