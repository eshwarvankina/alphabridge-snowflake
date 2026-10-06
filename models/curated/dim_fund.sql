with accounts as (

    select
        fund_code,
        account_id,
        min(position_date) as first_position_date,
        max(position_date) as last_position_date
    from {{ ref('stg_custodian_positions') }}
    where reject_reason is null
    group by fund_code, account_id

),

reference as (

    select * from {{ ref('fund_reference') }}

),

final as (

    select
        a.fund_code,
        a.account_id,
        r.fund_name,
        r.strategy,
        r.benchmark,
        a.first_position_date,
        a.last_position_date
    from accounts a
    left join reference r
        on a.fund_code = r.fund_code

)

select * from final