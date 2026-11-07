-- 01_deposit_journey.sql
-- Analysis 1: deposit journey funnel, new casino players, cohorts May–Dec 2019.

with players as (

    -- Population: new casino players with at least two full months of follow-up
    select *
    from analytics.dim_player
    where brand = 'casino'
      and player_type = 'new'
      and cohort_month between '2019-05-01' and '2019-12-01'

),

activity as (

    -- Was each player active 1 and 2 months after their cohort month?
    select
        player_id,
        bool_or(is_active and months_since_first_seen = 1) as active_m1,
        bool_or(is_active and months_since_first_seen = 2) as active_m2
    from analytics.fct_player_month
    group by player_id

),

flags as (

    -- One row per player, with a yes/no for each journey step
    select
        p.player_id,
        p.first_funding_attempt_date    is not null as tried_to_fund,
        p.first_successful_funding_date is not null as funded,
        p.first_deposit_date            is not null as first_deposit,
        p.second_deposit_date           is not null as second_deposit,
        coalesce(a.active_m1, false)                as active_m1,
        coalesce(a.active_m2, false)                as active_m2
    from players as p
    left join activity as a
        on p.player_id = a.player_id

),

funnel as (

    -- Each step only counts players who also passed every earlier step
    select 1 as step, 'New player' as step_name, count(*) as players
    from flags
    union all
    select 2, 'Tried to fund', count(*) filter (
        where tried_to_fund)
    from flags
    union all
    select 3, 'Funded successfully', count(*) filter (
        where tried_to_fund and funded)
    from flags
    union all
    select 4, 'First deposit into gambling', count(*) filter (
        where tried_to_fund and funded and first_deposit)
    from flags
    union all
    select 5, 'Second deposit', count(*) filter (
        where tried_to_fund and funded and first_deposit and second_deposit)
    from flags
    union all
    select 6, 'Active in month 1', count(*) filter (
        where tried_to_fund and funded and first_deposit and second_deposit and active_m1)
    from flags
    union all
    select 7, 'Still active in month 2', count(*) filter (
        where tried_to_fund and funded and first_deposit and second_deposit and active_m1 and active_m2)
    from flags

)

select
    step,
    step_name,
    players,
    round(100.0 * players / max(players) over (), 1)            as pct_of_new_players,
    round(100.0 * players / lag(players) over (order by step), 1) as pct_of_previous_step
from funnel
order by step;