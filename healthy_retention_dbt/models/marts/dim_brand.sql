-- dim_brand.sql
-- Brand dimension: one row per brand.

select *
from (
    values
        ('casino', 'Casino brand', 'US East Coast', 'America/New_York',    false),
        ('sports', 'Sports brand', 'US West Coast', 'America/Los_Angeles', true)
) as brands (brand, brand_label, region, local_time_zone, has_ach_funding)