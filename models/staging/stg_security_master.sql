with source as (

    select * from {{ source('raw', 'security_master') }}

),

typed as (

    select --cleansing data, column_names, spaes etc --> basic cleaning!!
        upper(trim(ticker))                  as ticker, 
        upper(trim(isin))                    as isin,
        trim(cusip)                          as cusip,
        trim(company_name)                   as company_name,
        trim(sector)                         as sector,
        trim(industry)                       as industry,
        upper(trim(exchange))                as exchange_code,
        case upper(trim(exchange))
            when 'NMS' then 'NASDAQ' --chaning the exchange code to a readble value
            when 'NYQ' then 'NYSE'
            else upper(trim(exchange))
        end                                  as exchange_name,
        upper(trim(currency))                as currency,
        _source_file                         as source_file,
        _file_row_number                     as file_row_number,
        _file_last_modified                  as file_last_modified,
        _loaded_at                           as loaded_at
    from source

),

final as (

select
        *,
    case
        when ticker is null or ticker = ''          then 'missing ticker' --handling missing and improper values
        when isin is null or length(isin) != 12     then 'invalid isin'
    end as reject_reason
from typed

)

select * from final