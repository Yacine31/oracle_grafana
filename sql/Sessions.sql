select
    username,
    nvl(machine, '<Unknown>') machine,
    nvl(program, '<Unknown>') program,
    count(*) session_count
from
    gv$session
where
    username is not null
group by
    username,
    machine,
    program