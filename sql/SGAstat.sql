select
    /* orasicent */
    pool as COMPONENT,
    round(sum(bytes) / 1024 / 1024, 0) as SIZE_MB
from
    v$sgastat
where
    POOL is not NULL
group by
    POOL
UNION
select
    /* orasicent */
    NAME as COMPONENT,
    round(bytes / 1024 / 1024, 0) as SIZE_MB
from
    v$sgastat
where
    POOL is NULL
order by
    2 desc
