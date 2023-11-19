select name, value from v$sysstat where name in 
('logons current', 'user commits', 'opened cursors current')
