for r in $(ps -eaf | grep pmon | egrep -v 'grep|ASM|APX1' | cut -d '_' -f3)
do
        export ORACLE_SID=$r
        export ORACLE_HOME=$(cat /etc/oratab | grep "^$r:" | cut -d: -f2)
        export LD_LIBRARY_PATH=$ORACLE_HOME/lib

        export script_dir=/home/oracle/oracle_grafana

        cd ${script_dir}
        git pull

        export INFLUXDB_TOKEN=KDDLLyCQ7TzdnW0zr1d0g2C3JbwvX1hgsyJb27DGnVwH8TFp9DUfaIqnC29y6HtWQyODajT20uFpO76AEQNyDw==

        /usr/bin/python3 ${script_dir}/getMetrics_influxv2.py --sid $r --verbose --influxdb-host srvorap --influxdb-port 8087 --influxdb-database influx --sql-directory ${script_dir}/sql

done
