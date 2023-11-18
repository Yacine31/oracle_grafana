select
    -- resetlogs_time,
    dest_id,
    sequence# as sequence_number,
    -- cast(cast(first_time as timestamp with time zone) at time zone 'UTC' as DATE) as "FIRST_TIME",
    -- completion_time,
    blocks*block_size as bytes
from 
    v$archived_log 
where 
    completion_time>sysdate - interval '1' day 
order by 
    completion_time,dest_id