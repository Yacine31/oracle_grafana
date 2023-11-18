-- select owner, count(*) "invalid_objects" FROM dba_objects WHERE status <> 'VALID' group by owner order by owner
select count(*) "invalid_objects" FROM dba_objects WHERE status <> 'VALID'