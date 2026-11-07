-- 05_payment_friction.sql
-- Analysis 5: do declined payments push new casino players away?

-- Query 1: hypothesis check — first funding attempt declined vs approved
with players as (

    select player_id, first_deposit_date
    from analytics.dim_player
    where brand = 'casino'
      and player_type = 'new'
      and first_funding_attempt_date is not null
      and cohort_month between '2019-05-01' and '2020-01-01'

),

first_attempt as (

    -- The earliest funding transaction per player (one row each)
    select distinct on (t.player_id)
        t.player_id,
        t.status as first_attempt_status
    from analytics.fct_transactions as t
    inner join players as p
        on t.player_id = p.player_id
    where t.transaction_category like 'wallet_funding%'
    order by t.player_id, t.ts_utc, t.transaction_id

),

month_1 as (

    select player_id, is_active as active_m1
    from analytics.fct_player_month
    where months_since_first_seen = 1

)

select
    fa.first_attempt_status,
    count(*)                                                        as players,
    round(100.0 * avg((p.first_deposit_date is not null)::int), 1)  as reached_first_deposit_pct,
    round(100.0 * avg(coalesce(m.active_m1, false)::int), 1)        as retention_m1_pct
from players as p
inner join first_attempt as fa
    on p.player_id = fa.player_id
left join month_1 as m
    on p.player_id = m.player_id
group by fa.first_attempt_status
order by fa.first_attempt_status;


-- Query 2: secondary view — number of declined funding attempts in the first 30 days
with players as (

    select player_id, first_funding_attempt_date
    from analytics.dim_player
    where brand = 'casino'
      and player_type = 'new'
      and first_funding_attempt_date is not null
      and cohort_month between '2019-05-01' and '2020-01-01'

),

declines_30d as (

    select
        p.player_id,
        count(t.transaction_id) filter (where t.status = 'DECLINED') as declines
    from players as p
    left join analytics.fct_transactions as t
        on  t.player_id = p.player_id
        and t.transaction_category like 'wallet_funding%'
        and t.date_pacific between p.first_funding_attempt_date
                               and p.first_funding_attempt_date + 29
    group by p.player_id

),

month_1 as (

    select player_id, is_active as active_m1
    from analytics.fct_player_month
    where months_since_first_seen = 1

)

select
    case
        when d.declines = 0 then '1: 0 declines'
        when d.declines = 1 then '2: 1 decline'
        when d.declines <= 5 then '3: 2-5 declines'
        else '4: 6+ declines'
    end                                                         as decline_group,
    count(*)                                                    as players,
    round(100.0 * count(*) / sum(count(*)) over (), 1)          as pct_of_players,
    round(100.0 * avg(coalesce(m.active_m1, false)::int), 1)    as retention_m1_pct
from declines_30d as d
left join month_1 as m
    on d.player_id = m.player_id
group by decline_group
order by decline_group;