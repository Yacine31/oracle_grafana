select 
    DATABASE_ROLE,
    OPEN_MODE,
    LOG_MODE,
    -- to_char(startup_time,'DD-MM-YYYY_HH24:MI') startup_time,
    to_char(startup_time,'DD-MM-YYYY HH24:MI') startup_time,
    STATUS,
    LOGINS
from v$instance, v$database
