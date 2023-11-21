SELECT 
       file_name, 
       tablespace_name, 
       bytes, 
       maxbytes,
       status, 
       autoextensible, 
       round((bytes/maxbytes)*100,2) percent_used, 
       online_status
  FROM dba_data_files
