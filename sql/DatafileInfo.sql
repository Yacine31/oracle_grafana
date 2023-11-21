SELECT 
       file_name, 
       tablespace_name, 
       bytes, 
       status, 
       autoextensible, 
       round((x.bytes/x.maxbytes)*100,2) percent_used, 
       online_status
  FROM dba_data_files
