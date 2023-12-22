-- select
--     -- resetlogs_time,
--     dest_id,
--     sequence# as sequence_number,
--     -- cast(cast(first_time as timestamp with time zone) at time zone 'UTC' as DATE) as "FIRST_TIME",
--     -- completion_time,
--     blocks*block_size as bytes
-- from 
--     v$archived_log 
-- where 
--     completion_time>sysdate - interval '1' day 
-- order by 
--     completion_time,dest_id

-- on compte le nombre d'archivelog et la taille de la dernière heure 
select 
    to_char(first_time, 'HH24') "Heure",
    sum(blocks*block_size) "Taille",
    count(1) "Total"
from v$archived_log
where 
    -- l'heure est l'heure actuelle
    to_char(first_time, 'HH24') = to_char(systimestamp, 'HH24')
    and
    -- le jour est aujourd'hui
    to_char(first_time, 'YYYYMMDD') = to_char(systimestamp, 'YYYYMMDD') 
group by to_char(first_time, 'HH24')
