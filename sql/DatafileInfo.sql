-- SELECT 
--        file_name, 
--        tablespace_name, 
--        bytes, 
--        maxbytes,
--        status, 
--        autoextensible, 
--        round((bytes/maxbytes)*100,2) percent_used, 
--        online_status
--   FROM dba_data_files


select
    d.file_name,
    a.bytes_alloc file_size,
    a.bytes_alloc - nvl(b.bytes_free, 0) space_used,
    nvl(b.bytes_free, 0)  space_free,
    a.maxbytes maxsize,
    (a.bytes_alloc - nvl(b.bytes_free, 0)) / a.maxbytes * 100 percent_used
from
    (
        select
            f.file_id,
            sum(f.bytes) bytes_alloc,
            sum(decode(f.autoextensible, 'YES', f.maxbytes, 'NO', f.bytes)) maxbytes
        from
            dba_data_files f
        group by
            file_id
    ) a,
    (
        select
            f.file_id,
            sum(f.bytes) bytes_free
        from
            dba_free_space f
        group by
            file_id
    ) b,
    dba_data_files d
where
    a.file_id = b.file_id (+) and d.file_id=b.file_id
