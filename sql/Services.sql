select
    service_name,
    count(*) as session_count
from
    gv$session
group by
    service_name