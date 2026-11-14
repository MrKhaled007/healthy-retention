-- Row counts at each layer, so the report can show nothing was lost by accident
with counts as (

    select 1 as layer_order, 'Raw file' as layer, 'casino' as brand, count(*) as row_count
    from {{ source('raw', 'casino_transactions') }}

    union all
    select 1, 'Raw file', 'sports', count(*)
    from {{ source('raw', 'sports_transactions') }}

    union all
    select 2, 'Staging (cleaned)', 'casino', count(*)
    from {{ ref('stg_casino_transactions') }}

    union all
    select 2, 'Staging (cleaned)', 'sports', count(*)
    from {{ ref('stg_sports_transactions') }}

    union all
    select 3, 'Fact table (study window)', brand, count(*)
    from {{ ref('fct_transactions') }}
    group by brand

    union all
    select 4, 'Players', brand, count(*)
    from {{ ref('dim_player') }}
    group by brand

)

select * from counts