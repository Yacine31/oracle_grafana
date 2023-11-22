-- select to_char(ORIGINATING_TIMESTAMP,'YYYY-MM-DD HH24:MI:SS') || ' - ' || MESSAGE_TEXT "MESSAGE_TEXT"
--   from V$DIAG_ALERT_EXT
--   where MESSAGE_TEXT like 'ORA-%' AND originating_timestamp >= SYSDATE - 30
-- --  order by ORIGINATING_TIMESTAMP


select to_char(ORIGINATING_TIMESTAMP, 'DD-MM-YYYY HH-MM-SS') || ' - ' || message_text "MESSAGE_TEXT"
FROM X$DBGALERTEXT
WHERE originating_timestamp > systimestamp - 30
AND regexp_like(message_text, '(ORA-)')
AND rownum <=100
order by originating_timestamp  desc
