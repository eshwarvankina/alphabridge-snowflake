with spine as (

{{ dbt_utils.date_spine(
    datepart   = "day",
    start_date = "cast('2023-01-01' as date)",
    end_date   = "dateadd(year, 2, date_trunc('year', current_date()))"
) }}

),

trading_days as (

    select distinct trade_date from {{ ref('prices_daily') }}

),

final as (

    select
        cast(s.date_day as date)                     as calendar_date,
        year(s.date_day)                             as year,
        quarter(s.date_day)                          as quarter,
        month(s.date_day)                            as month,
        monthname(s.date_day)                        as month_name,
        dayname(s.date_day)                          as day_name,
        dayofweekiso(s.date_day) in (6, 7)           as is_weekend,
        last_day(s.date_day, 'month') = s.date_day   as is_month_end,
        t.trade_date is not null                     as is_trading_day
    from spine s
    left join trading_days t
        on cast(s.date_day as date) = t.trade_date

)

select * from final