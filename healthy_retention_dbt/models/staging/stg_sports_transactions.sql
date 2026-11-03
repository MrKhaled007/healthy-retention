-- stg_sports_transactions.sql
-- Cleaned sports transactions: deduplicated, typed, in the analysis window.

with source as (

    select * from {{ source('raw', 'sports_transactions') }}

),

deduplicated as (

    -- Decision 12: exact duplicate rows are reduced to one copy
    select distinct
        req_time_utc,
        transaction_type,
        transaction_amount,
        status,
        account_identifier
    from source

),

typed as (

    select
        md5(concat_ws('|', req_time_utc, transaction_type, transaction_amount, status, account_identifier))
                                                as transaction_id,
        'sports'                                as brand,
        'sports_' || account_identifier         as player_id,
        account_identifier,
        req_time_utc::timestamptz               as ts_utc,
        transaction_type,
        case transaction_type
            when 'LOYALTYCARDCREDITCL'  then 'wallet_funding_card'
            when 'LOYALTYCARDCREDITACH' then 'wallet_funding_ach'
            when 'LOYALTYCARDDEBIT'     then 'deposit_to_gambling'
            when 'LOYALTYCARDCREDIT'    then 'withdrawal_from_gambling'
        end                                     as transaction_category,
        transaction_amount::numeric(12, 2)      as amount_usd,
        status,
        status = 'APPROVED'                     as is_approved
    from deduplicated
    -- Decision 11: rows with unknown status ("NA") are excluded
    where status in ('APPROVED', 'DECLINED')

),

with_time_zones as (

    select
        *,
        -- Decision 1: days and months in Pacific time
        ts_utc at time zone 'America/Los_Angeles'           as ts_pacific,
        (ts_utc at time zone 'America/Los_Angeles')::date   as date_pacific,
        -- Decision 10: sports local time is US Pacific
        ts_utc at time zone 'America/Los_Angeles'           as ts_local
    from typed

)

-- Decision 2: analysis window 1 Mar 2019 – 29 Feb 2020 (Pacific)
select *
from with_time_zones
where date_pacific between '2019-03-01' and '2020-02-29'