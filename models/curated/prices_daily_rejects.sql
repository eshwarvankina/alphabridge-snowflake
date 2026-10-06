with final as (

    select
        source_file,
        file_row_number,
        reject_reason,
        loaded_at
    from {{ ref('stg_prices_daily') }}
    where reject_reason is not null

)

select * from final