select to_char(ORIGINATING_TIMESTAMP, 'DD-MM-YYYY') date_jour, count(*) nb_erreurs 
FROM X$DBGALERTEXT
WHERE originating_timestamp > systimestamp - 30 AND 
regexp_like(message_text, '(ORA-)')
group by to_char(ORIGINATING_TIMESTAMP, 'DD-MM-YYYY')
order by to_char(ORIGINATING_TIMESTAMP, 'DD-MM-YYYY') asc