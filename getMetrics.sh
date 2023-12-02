for r in $(ps -eaf | grep pmon | egrep -v 'grep|ASM|APX1' | cut -d '_' -f3)
do
        export ORACLE_SID=$r
        export ORACLE_HOME=$(cat /etc/oratab | grep "^$r:" | cut -d: -f2)
        export LD_LIBRARY_PATH=$ORACLE_HOME/lib

        export script_dir=/home/oracle/oracle_grafana

        cd ${script_dir}
        git pull

        /usr/bin/python3 ${script_dir}/getMetrics.py --sid $r --verbose --influxdb-host srvorap --influxdb-port 8086 --influxdb-database influx --sql-directory ${script_dir}/sql

done
