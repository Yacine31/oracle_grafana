select
    round(sum(PERCENT_SPACE_USED) - sum(PERCENT_SPACE_RECLAIMABLE),2) PERCENT_SPACE_USED,
    round(sum(PERCENT_SPACE_RECLAIMABLE),2) PERCENT_RECLAIMABLE
from
    v$flash_recovery_area_usage
