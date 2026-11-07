-- 04_healthy_retention.sql
-- Analysis 4: how much month-3 retention comes from early high-intensity players (casino).

with players as (

    -- New casino depositors, cohorts May–Nov 2019 (month 3 is inside the data)
    select player_id, first_deposit_date
    from analytics.dim_player
    where brand = 'casino'
      and player_type = 'new'
      and first_deposit_date is not null
      and cohort_month between '2019-05-01' and '2019-11-01'

),

first_30_days as (

    -- Approved deposit money in the 30 days starting on the first deposit date
    select
        p.player_id,
        coalesce(sum(t.approved_amount_usd), 0) as first_30d_deposit_usd
    from players as p
    left join analytics.fct_transactions as t
        on  t.player_id = p.player_id
        and t.transaction_category = 'deposit_to_gambling'
        and t.date_pacific between p.first_deposit_date and p.first_deposit_date + 29
    group by p.player_id

),

grouped as (

    select
        player_id,
        case
            when first_30d_deposit_usd > 1038.33 then 'Early high-intensity'
            else 'Other depositors'
        end as player_group
    from first_30_days

),

activity as (

    -- Months 0 to 3 after the cohort month, for every player
    select
        g.player_group,
        pm.player_id,
        pm.months_since_first_seen  as month_k,
        pm.is_active,
        pm.deposits_amount_usd
    from analytics.fct_player_month as pm
    inner join grouped as g
        on pm.player_id = g.player_id
    where pm.months_since_first_seen between 0 and 3

)

select
    player_group,
    count(distinct player_id)                                                   as players,
    round(100.0 * count(distinct player_id)
          / sum(count(distinct player_id)) over (), 1)                          as pct_of_players,
    round(100.0 * avg(is_active::int) filter (where month_k = 1), 1)            as retention_m1_pct,
    round(100.0 * avg(is_active::int) filter (where month_k = 2), 1)            as retention_m2_pct,
    round(100.0 * avg(is_active::int) filter (where month_k = 3), 1)            as retention_m3_pct,
    count(*) filter (where month_k = 3 and is_active)                           as active_in_m3,
    round(100.0 * count(*) filter (where month_k = 3 and is_active)
          / sum(count(*) filter (where month_k = 3 and is_active)) over (), 1)  as pct_of_m3_active,
    round(sum(deposits_amount_usd) filter (where month_k = 3), 0)               as m3_deposit_money_usd,
    round(100.0 * sum(deposits_amount_usd) filter (where month_k = 3)
          / sum(sum(deposits_amount_usd) filter (where month_k = 3)) over (), 1) as pct_of_m3_money
from activity
group by player_group
order by player_group;