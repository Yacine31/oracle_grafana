SELECT 
       file_name, 
       tablespace_name, 
       bytes, 
       status, 
       autoextensible, 
       maxbytes, 
       online_status
  FROM dba_data_files
 ORDER BY
           file_name