-- select 
--     DATABASE_ROLE,
--     OPEN_MODE,
--     LOG_MODE,
--     -- to_char(startup_time,'DD-MM-YYYY_HH24:MI') startup_time,
--     to_char(startup_time,'DD-MM-YYYY HH24:MI') startup_time,
--     STATUS,
--     LOGINS
-- from v$instance, v$database

select 
    i.host_name,
    i.instance_name,
    d.DATABASE_ROLE,
    d.OPEN_MODE,
    d.LOG_MODE,
    to_char(startup_time,'DD-MM-YYYY HH24:MI') startup_time,
    i.STATUS,
    i.version,
    i.LOGINS
from v$instance i, v$database d
