-- 02_retention_cohorts.sql
-- Analysis 2: monthly retention by cohort, new casino players.

-- Query 1: retention for every cohort and every month after arrival
with new_players as (

    select player_id, cohort_month
    from analytics.dim_player
    where brand = 'casino'
      and player_type = 'new'

)

select
    to_char(p.cohort_month, 'YYYY-MM')                  as cohort,
    pm.months_since_first_seen                          as month_k,
    count(*)                                            as cohort_size,
    count(*) filter (where pm.is_active)                as active_players,
    round(100.0 * avg(pm.is_active::int), 1)            as retention_pct
from analytics.fct_player_month as pm
inner join new_players as p
    on pm.player_id = p.player_id
where pm.months_since_first_seen >= 1
group by p.cohort_month, pm.months_since_first_seen
order by p.cohort_month, pm.months_since_first_seen;


-- Query 2: hypothesis check — month-1 retention per cohort vs the pooled average
with new_players as (

    select player_id, cohort_month
    from analytics.dim_player
    where brand = 'casino'
      and player_type = 'new'

),

month_1 as (

    select
        p.cohort_month,
        count(*)                                as cohort_size,
        count(*) filter (where pm.is_active)    as active_players
    from analytics.fct_player_month as pm
    inner join new_players as p
        on pm.player_id = p.player_id
    where pm.months_since_first_seen = 1
    group by p.cohort_month

)

select
    to_char(cohort_month, 'YYYY-MM')                                        as cohort,
    cohort_size,
    round(100.0 * active_players / cohort_size, 1)                          as m1_retention_pct,
    round(100.0 * sum(active_players) over () / sum(cohort_size) over (), 1) as pooled_avg_pct,
    round(100.0 * active_players / cohort_size
          - 100.0 * sum(active_players) over () / sum(cohort_size) over (), 1) as diff_pts
from month_1
order by cohort_month;