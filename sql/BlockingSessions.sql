SELECT /*+ RULE */
    s.username,
    s.osuser "OS_USER",
    s.machine,
    s.module,
    l.type,
    count(*) "SESSION_COUNT",
    decode(l.block,0,'WAITING',1,'BLOCKING') block,
    decode(o.object_name,NULL,NULL, o.owner||'.'||o.object_name) OBJECT
FROM v$process p, v$Lock l, 
v$session s left outer join dba_objects o 
    on (s.ROW_WAIT_OBJ# = o.OBJECT_ID)
where p.addr = s.paddr
    and s.sid=l.sid
    and
    (l.id1,l.id2,l.type) in
        (SELECT l2.id1, l2.id2, l2.type
        FROM V$LOCK l2
        WHERE l2.request<>0)
GROUP BY     s.username,
    s.osuser,
    s.machine,
    s.module,
    l.type, 
    l.block,
    decode(o.object_name,NULL,NULL, o.owner||'.'||o.object_name)
