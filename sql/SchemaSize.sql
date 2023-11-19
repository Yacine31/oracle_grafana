select
    *
from
    (
        select
            ds.owner,
            sum(ds.bytes) schema_size,
            du.default_tablespace
        from
            dba_segments ds,
            dba_users du
        where
            ds.OWNER = du.USERNAME
        group by
            ds.owner,
            du.default_tablespace
        order by
            ds.owner
    )
