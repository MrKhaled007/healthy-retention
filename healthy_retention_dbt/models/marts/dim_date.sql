-- dim_date.sql
-- Calendar dimension: one row per day in the analysis window (Pacific time).

with days as (

    select generate_series(
        '2019-03-01'::date,
        '2020-02-29'::date,
        interval '1 day'
    )::date as date_pacific

)

select
    date_pacific,
    date_trunc('month', date_pacific)::date     as month_start,
    to_char(date_pacific, 'YYYY-MM')            as year_month,
    to_char(date_pacific, 'Mon YYYY')           as month_label,
    extract(year from date_pacific)::int        as year,
    extract(month from date_pacific)::int       as month_number,
    extract(quarter from date_pacific)::int     as quarter,
    date_trunc('week', date_pacific)::date      as week_start,
    extract(isodow from date_pacific)::int      as day_of_week,
    to_char(date_pacific, 'Dy')                 as day_name,
    extract(isodow from date_pacific) in (6, 7) as is_weekend
from days