select
    /* orasicent */
    do.OWNER,
    do.OBJECT_TYPE,
    count(do.OBJECT_NAME) OBJECT_COUNT
from
    dba_objects do,
    dba_users du
where
    do.OWNER = du.USERNAME
    and du.DEFAULT_TABLESPACE not in (
        'SYSTEM',
        'SYSAUX',
        'USERS',
        'XDB',
        'DRSYS',
        'ODM',
        'CWMLITE',
        'TOOLS'
    )
group by
    do.OWNER,
    do.OBJECT_TYPE
order by
    do.OWNER,
    do.OBJECT_TYPE