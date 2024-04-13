{{config(materialized='table')}}
with days as (
    {{dbt.date_spine(
        'day',
        "DATE(2000,01,01)",
        "DATE(2030,01,01)"
    )
    }}
),

final as (
    select cast(date_day as date) as date_day
    from days
)

select *
from final