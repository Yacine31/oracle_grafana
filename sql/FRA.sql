col PERCENT_SPACE_USED for 99,9
col PERCENT_RECLAIMABLE for 99,9
select
    sum(PERCENT_SPACE_USED) - sum(PERCENT_SPACE_RECLAIMABLE) PERCENT_SPACE_USED,
    sum(PERCENT_SPACE_RECLAIMABLE) PERCENT_RECLAIMABLE
from
    v$flash_recovery_area_usage
/