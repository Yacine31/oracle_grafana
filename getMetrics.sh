for r in $(ps -eaf | grep pmon | egrep -v 'grep|ASM|APX1' | cut -d '_' -f3)
do
        export ORAENV_ASK=NO
        export ORACLE_SID=$r
        . oraenv -s > /dev/null
        
        export script_dir=/home/oracle/oracle_grafana

        /usr/bin/python3 ${script_dir}/getMetrics.py --sid ORCL --influxdb-host srvorap --influxdb-port 8086 --influxdb-database influx --sql-directory ${script_dir}/sql

done
