-- fct_player_month.sql
-- One row per player per month, from cohort month to Feb 2020, including inactive months.

with transactions as (

    select * from {{ ref('fct_transactions') }}

),

players as (

    select player_id, brand, cohort_month
    from {{ ref('dim_player') }}

),

months as (

    select distinct month_start
    from {{ ref('dim_date') }}

),

player_months as (

    -- Every month from the player's cohort month onwards
    select
        p.player_id,
        p.brand,
        p.cohort_month,
        m.month_start as month_pacific
    from players as p
    inner join months as m
        on m.month_start >= p.cohort_month

),

monthly_activity as (

    select
        player_id,
        month_pacific,
        count(*) filter (
            where transaction_category = 'deposit_to_gambling' and is_approved
        )                                                           as deposits_count,
        sum(approved_amount_usd) filter (
            where transaction_category = 'deposit_to_gambling'
        )                                                           as deposits_amount_usd,
        count(distinct date_pacific) filter (
            where transaction_category = 'deposit_to_gambling' and is_approved
        )                                                           as deposit_days,
        count(*) filter (
            where transaction_category = 'withdrawal_from_gambling' and is_approved
        )                                                           as withdrawals_count,
        sum(approved_amount_usd) filter (
            where transaction_category = 'withdrawal_from_gambling'
        )                                                           as withdrawals_amount_usd,
        count(*) filter (
            where transaction_category like 'wallet_funding%'
        )                                                           as funding_attempts,
        count(*) filter (
            where transaction_category like 'wallet_funding%' and not is_approved
        )                                                           as funding_declines
    from transactions
    group by player_id, month_pacific

)

select
    pm.player_id || '_' || to_char(pm.month_pacific, 'YYYY-MM')    as player_month_id,
    pm.player_id,
    pm.brand,
    pm.cohort_month,
    pm.month_pacific,
    -- 0 = the cohort month, 1 = the month after, and so on
    (extract(year from age(pm.month_pacific, pm.cohort_month)) * 12
     + extract(month from age(pm.month_pacific, pm.cohort_month)))::int
                                                                    as months_since_first_seen,
    coalesce(a.deposits_count, 0)                                   as deposits_count,
    coalesce(a.deposits_amount_usd, 0)                              as deposits_amount_usd,
    coalesce(a.deposit_days, 0)                                     as deposit_days,
    coalesce(a.withdrawals_count, 0)                                as withdrawals_count,
    coalesce(a.withdrawals_amount_usd, 0)                           as withdrawals_amount_usd,
    coalesce(a.funding_attempts, 0)                                 as funding_attempts,
    coalesce(a.funding_declines, 0)                                 as funding_declines,
    -- Decision 13: active = at least one approved deposit into gambling
    coalesce(a.deposits_count, 0) > 0                               as is_active
from player_months as pm
left join monthly_activity as a
    on  pm.player_id = a.player_id
    and pm.month_pacific = a.month_pacific