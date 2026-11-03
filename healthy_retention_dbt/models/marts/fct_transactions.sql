-- fct_transactions.sql
-- Fact table: one row per transaction, both brands.

with casino as (

    select * from {{ ref('stg_casino_transactions') }}

),

sports as (

    select * from {{ ref('stg_sports_transactions') }}

),

unioned as (

    select * from casino
    union all
    select * from sports

)

select
    brand || '_' || transaction_id                      as transaction_id,
    player_id,
    brand,
    date_pacific,
    date_trunc('month', date_pacific)::date             as month_pacific,
    ts_utc,
    ts_pacific,
    ts_local,
    transaction_type,
    transaction_category,
    status,
    is_approved,
    amount_usd,
    -- Decision 3: declined amounts are never summed
    case when is_approved then amount_usd else 0 end    as approved_amount_usd
from unioned