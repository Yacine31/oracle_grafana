select
        b.input_type,
        b.status,
        to_char(b.start_time,'DD-MM-YYYY HH24:MI') "Start Time",
        to_char(b.end_time,'DD-MM-YYYY HH24:MI') "End Time",
        b.output_device_type device_type,
        b.input_bytes_display,
        b.output_bytes_display
FROM v$rman_backup_job_details b
WHERE b.start_time > (SYSDATE - 30)
ORDER BY b.start_time asc
