select to_char(ORIGINATING_TIMESTAMP,'YYYY-MM-DD HH24:MI:SS') || ' - ' || MESSAGE_TEXT "MESSAGE_TEXT"
  from V$DIAG_ALERT_EXT
  where MESSAGE_TEXT like 'ORA-%' AND originating_timestamp >= SYSDATE - 30
--  order by ORIGINATING_TIMESTAMP