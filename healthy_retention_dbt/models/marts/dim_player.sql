-- dim_player.sql
-- Player dimension: one row per player, with journey milestones, activity flags,
-- deposit segment, early spending group and payment friction.

with transactions as (

    select * from {{ ref('fct_transactions') }}

),

player_months as (

    select * from {{ ref('fct_player_month') }}

),

approved_deposits as (

    select
        player_id,
        date_pacific,
        row_number() over (
            partition by player_id
            order by ts_utc, transaction_id
        ) as deposit_number
    from transactions
    where transaction_category = 'deposit_to_gambling'
      and is_approved

),

second_deposits as (

    select
        player_id,
        date_pacific as second_deposit_date
    from approved_deposits
    where deposit_number = 2

),

milestones as (

    select
        player_id,
        max(brand)                                              as brand,
        min(date_pacific)                                       as first_seen_date,
        max(date_pacific)                                       as last_seen_date,
        min(date_pacific) filter (
            where transaction_category like 'wallet_funding%'
        )                                                       as first_funding_attempt_date,
        min(date_pacific) filter (
            where transaction_category like 'wallet_funding%' and is_approved
        )                                                       as first_successful_funding_date,
        min(date_pacific) filter (
            where transaction_category = 'deposit_to_gambling' and is_approved
        )                                                       as first_deposit_date,
        min(date_pacific) filter (
            where transaction_category = 'withdrawal_from_gambling' and is_approved
        )                                                       as first_withdrawal_date
    from transactions
    group by player_id

),

activity as (

    -- Active 1, 2 and 3 months after the cohort month (decision 13)
    select
        player_id,
        bool_or(is_active and months_since_first_seen = 1) as active_m1,
        bool_or(is_active and months_since_first_seen = 2) as active_m2,
        bool_or(is_active and months_since_first_seen = 3) as active_m3
    from player_months
    group by player_id

),

deposit_totals as (

    -- Analysis 3: totals from the month of the first deposit to Feb 2020
    select
        m.player_id,
        m.brand,
        sum(pm.deposits_count)          as total_deposits,
        sum(pm.deposits_amount_usd)     as total_deposit_usd,
        count(*)                        as months_observed
    from player_months as pm
    inner join milestones as m
        on pm.player_id = m.player_id
    where m.first_deposit_date is not null
      and pm.month_pacific >= date_trunc('month', m.first_deposit_date)
    group by m.player_id, m.brand

),

deposit_rates as (

    select
        *,
        total_deposit_usd / months_observed as monthly_deposit_usd
    from deposit_totals

),

thresholds as (

    -- Median and 90th percentile of repeat depositors, per brand (decision 15)
    select
        brand,
        percentile_cont(0.5) within group (order by monthly_deposit_usd) as p50,
        percentile_cont(0.9) within group (order by monthly_deposit_usd) as p90
    from deposit_rates
    where total_deposits >= 2
    group by brand

),

segments as (

    select
        r.player_id,
        r.monthly_deposit_usd,
        case
            when r.total_deposits = 1           then 'One-and-done'
            when r.monthly_deposit_usd < t.p50  then 'Light'
            when r.monthly_deposit_usd <= t.p90 then 'Regular'
            else                                     'High-intensity'
        end as deposit_segment
    from deposit_rates as r
    inner join thresholds as t
        on r.brand = t.brand

),

first_30_days as (

    -- Analysis 4 and 5: first 30 days after the first deposit / first funding attempt
    select
        m.player_id,
        coalesce(sum(t.approved_amount_usd) filter (
            where t.transaction_category = 'deposit_to_gambling'
              and t.date_pacific between m.first_deposit_date and m.first_deposit_date + 29
        ), 0)                                                   as first_30d_deposit_usd,
        count(t.transaction_id) filter (
            where t.transaction_category like 'wallet_funding%'
              and not t.is_approved
              and t.date_pacific between m.first_funding_attempt_date
                                     and m.first_funding_attempt_date + 29
        )                                                       as funding_declines_first_30d
    from milestones as m
    left join transactions as t
        on m.player_id = t.player_id
    group by m.player_id

),

first_attempt as (

    -- Analysis 5: status of the earliest funding attempt
    select distinct on (player_id)
        player_id,
        status as first_funding_attempt_status
    from transactions
    where transaction_category like 'wallet_funding%'
    order by player_id, ts_utc, transaction_id

),

combined as (

    select
        m.player_id,
        m.brand,
        m.first_seen_date,
        date_trunc('month', m.first_seen_date)::date            as cohort_month,
        -- Decision 7: new players are first seen on or after 1 May 2019
        case
            when m.first_seen_date >= '2019-05-01' then 'new'
            else 'existing'
        end                                                     as player_type,
        m.first_funding_attempt_date,
        m.first_successful_funding_date,
        m.first_deposit_date,
        s.second_deposit_date,
        m.first_withdrawal_date,
        m.last_seen_date,
        coalesce(a.active_m1, false)                            as active_m1,
        coalesce(a.active_m2, false)                            as active_m2,
        coalesce(a.active_m3, false)                            as active_m3,
        coalesce(seg.deposit_segment, 'No deposit')             as deposit_segment,
        seg.monthly_deposit_usd,
        f.first_30d_deposit_usd,
        -- Decision 16: early high-intensity = above the brand's 90th percentile in the first 30 days
        (m.first_deposit_date is not null
         and f.first_30d_deposit_usd > t.p90)                   as is_early_high_intensity,
        fa.first_funding_attempt_status,
        f.funding_declines_first_30d
    from milestones as m
    left join second_deposits as s
        on m.player_id = s.player_id
    left join activity as a
        on m.player_id = a.player_id
    left join segments as seg
        on m.player_id = seg.player_id
    left join first_30_days as f
        on m.player_id = f.player_id
    left join first_attempt as fa
        on m.player_id = fa.player_id
    left join thresholds as t
        on m.brand = t.brand

)

select
    *,
    -- Furthest step reached in the deposit journey (Analysis 1).
    -- Each step requires all earlier steps, so step k count = players with journey_stage >= k.
    case
        when first_funding_attempt_date is null     then 1
        when first_successful_funding_date is null  then 2
        when first_deposit_date is null             then 3
        when second_deposit_date is null            then 4
        when not active_m1                          then 5
        when not active_m2                          then 6
        else                                             7
    end                                                         as journey_stage
from combined