-- dim_player.sql
-- Player dimension: one row per player, with journey milestones.

with transactions as (

    select * from {{ ref('fct_transactions') }}

),

approved_deposits as (

    -- Number each player's approved deposits into gambling: 1st, 2nd, 3rd...
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

)

select
    m.player_id,
    m.brand,
    m.first_seen_date,
    date_trunc('month', m.first_seen_date)::date                as cohort_month,
    -- Decision 7: new players are first seen on or after 1 May 2019
    case
        when m.first_seen_date >= '2019-05-01' then 'new'
        else 'existing'
    end                                                         as player_type,
    m.first_funding_attempt_date,
    m.first_successful_funding_date,
    m.first_deposit_date,
    s.second_deposit_date,
    m.first_withdrawal_date,
    m.last_seen_date
from milestones as m
left join second_deposits as s
    on m.player_id = s.player_id