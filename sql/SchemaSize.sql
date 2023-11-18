select
    *
from
    (
        select
            ds.owner,
            round(sum(ds.bytes) / 1024 / 1024) schema_size_mega,
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
