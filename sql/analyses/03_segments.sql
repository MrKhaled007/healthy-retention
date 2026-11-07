-- 03_segments.sql
-- Analysis 3: rule-based depositor segments, casino players.

-- Query 1: the two thresholds (median and 90th percentile of repeat depositors)
with casino_players as (

    select player_id, first_deposit_date
    from analytics.dim_player
    where brand = 'casino'
      and first_deposit_date is not null

),

player_totals as (

    -- Each player's totals from the month of their first deposit to Feb 2020
    select
        p.player_id,
        sum(pm.deposits_count)          as deposits,
        sum(pm.deposits_amount_usd)     as deposit_amount_usd,
        count(*)                        as months_observed
    from analytics.fct_player_month as pm
    inner join casino_players as p
        on pm.player_id = p.player_id
    where pm.month_pacific >= date_trunc('month', p.first_deposit_date)
    group by p.player_id

)

select
    round(percentile_cont(0.5) within group (order by deposit_amount_usd / months_observed)::numeric, 2)
        as median_monthly_usd,
    round(percentile_cont(0.9) within group (order by deposit_amount_usd / months_observed)::numeric, 2)
        as p90_monthly_usd
from player_totals
where deposits >= 2;


-- Query 2: segment profile and share of deposit money
with casino_players as (

    select player_id, first_deposit_date
    from analytics.dim_player
    where brand = 'casino'
      and first_deposit_date is not null

),

player_totals as (

    select
        p.player_id,
        sum(pm.deposits_count)          as deposits,
        sum(pm.deposits_amount_usd)     as deposit_amount_usd,
        sum(pm.deposit_days)            as deposit_days,
        sum(pm.funding_declines)        as funding_declines,
        count(*)                        as months_observed
    from analytics.fct_player_month as pm
    inner join casino_players as p
        on pm.player_id = p.player_id
    where pm.month_pacific >= date_trunc('month', p.first_deposit_date)
    group by p.player_id

),

with_rate as (

    select
        *,
        deposit_amount_usd / months_observed    as monthly_amount_usd
    from player_totals

),

thresholds as (

    select
        percentile_cont(0.5) within group (order by monthly_amount_usd) as p50,
        percentile_cont(0.9) within group (order by monthly_amount_usd) as p90
    from with_rate
    where deposits >= 2

),

segmented as (

    select
        w.*,
        case
            when w.deposits = 1              then '1 One-and-done'
            when w.monthly_amount_usd < t.p50  then '2 Light'
            when w.monthly_amount_usd <= t.p90 then '3 Regular'
            else                                  '4 High-intensity'
        end as segment
    from with_rate as w
    cross join thresholds as t

)

select
    segment,
    count(*)                                                            as players,
    round(100.0 * count(*) / sum(count(*)) over (), 1)                  as pct_of_players,
    round(sum(deposit_amount_usd), 0)                                   as deposit_money_usd,
    round(100.0 * sum(deposit_amount_usd) / sum(sum(deposit_amount_usd)) over (), 1)
                                                                        as pct_of_deposit_money,
    round(percentile_cont(0.5) within group (order by monthly_amount_usd)::numeric, 0)
                                                                        as median_monthly_usd,
    round(avg(deposit_days::numeric / months_observed), 1)              as avg_deposit_days_per_month,
    round(avg(funding_declines), 1)                                     as avg_funding_declines
from segmented
group by segment
order by segment;