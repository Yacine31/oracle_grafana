select
    a.tablespace_name,
    -- t.contents,
    round(a.bytes_alloc / 1024 / 1024) megs_alloc,
    round((a.bytes_alloc - nvl(b.bytes_free, 0)) / 1024 / 1024) megs_used,
    round(nvl(b.bytes_free, 0) / 1024 / 1024) megs_free,
    -- 100 - round((nvl(b.bytes_free, 0) / a.bytes_alloc) * 100) Pct_used,
    -- round((nvl(b.bytes_free, 0) / a.bytes_alloc) * 100) Pct_Free,
    round(maxbytes / 1048576) Max,
    round((a.bytes_alloc - nvl(b.bytes_free, 0)) / maxbytes * 100) Pct_Used_Max
    -- 100 - round((a.bytes_alloc - nvl(b.bytes_free, 0)) / maxbytes * 100) Pct_Free_Max
from
    (
        select
            f.tablespace_name,
            sum(f.bytes) bytes_alloc,
            sum(decode(f.autoextensible, 'YES', f.maxbytes, 'NO', f.bytes)) maxbytes
        from
            dba_data_files f
        group by
            tablespace_name
    ) a,
    (
        select
            f.tablespace_name,
            sum(f.bytes) bytes_free
        from
            dba_free_space f
        group by
            tablespace_name
    ) b,
    dba_tablespaces t
where
    a.tablespace_name = b.tablespace_name (+)
    and b.tablespace_name = t.tablespace_name
union all
select
    h.tablespace_name,
    -- dt.contents,
    round(sum(h.bytes_free + h.bytes_used) / 1048576) megs_alloc,
    round(sum(nvl(p.bytes_used, 0)) / 1048576) megs_used,
    round(sum((h.bytes_free + h.bytes_used) - nvl(p.bytes_used, 0)) / 1048576) megs_free,
    -- 100 - round((sum((h.bytes_free + h.bytes_used) - nvl(p.bytes_used, 0)) / sum(h.bytes_used + h.bytes_free)) * 100) pct_used,
    -- round((sum((h.bytes_free + h.bytes_used) - nvl(p.bytes_used, 0)) / sum(h.bytes_used + h.bytes_free)) * 100) Pct_Free,
    round(sum(f.maxbytes) / 1048576) max,
    round((sum(h.bytes_free + h.bytes_used) - sum((h.bytes_free + h.bytes_used) - nvl(p.bytes_used, 0))) / sum(f.maxbytes) * 100) "Pct_Used%Max"
    -- 100 - round((sum(h.bytes_free + h.bytes_used) - sum((h.bytes_free + h.bytes_used) - nvl(p.bytes_used, 0))) / decode(sum(f.maxbytes),0,sum(h.bytes_free + h.bytes_used),sum(f.maxbytes)) * 100) "Pct_Free%Max"
from
    sys.v_$temp_space_header h,
    sys.v_$temp_extent_pool p,
    dba_temp_files f,
    dba_tablespaces dt
where
    p.file_id(+) = h.file_id
    and p.tablespace_name(+) = h.tablespace_name
    and f.file_id = h.file_id
    and f.tablespace_name = h.tablespace_name
    and h.tablespace_name = dt.tablespace_name
group by
    h.tablespace_name,
    dt.contents
order by
    1
