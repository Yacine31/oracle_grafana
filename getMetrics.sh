for sid in $(ps -eaf | grep pmon | egrep -v 'grep|\+ASM' | cut -d '_' -f3)
do
        export ORACLE_SID=$sid
        export ORACLE_HOME=$(cat /etc/oratab | grep "^$sid:" | cut -d: -f2)
        export LD_LIBRARY_PATH=$ORACLE_HOME/lib

        export SCRIPT_DIR=/home/oracle/oracle_grafana

        cd ${SCRIPT_DIR}
        git pull

        ## envoyer les données vers l'environnement de prod sur la VM grafana
        INFLUX_HOST=192.168.31.3
        INFLUX_PORT=8086
        INFLUX_DB=telegraf
        
        /usr/bin/python3 ${SCRIPT_DIR}/getMetrics.py --sid $sid --verbose --influxdb-host ${INFLUX_HOST} --influxdb-port ${INFLUX_PORT} --influxdb-database ${INFLUX_DB}  --sql-directory ${SCRIPT_DIR}/sql

        
        INFLUX_HOST=51.38.225.236
        INFLUX_PORT=8086
        INFLUX_DB=influx

        /usr/bin/python3 ${SCRIPT_DIR}/getMetrics.py --sid $sid --verbose --influxdb-host ${INFLUX_HOST} --influxdb-port ${INFLUX_PORT} --influxdb-database ${INFLUX_DB}  --sql-directory ${SCRIPT_DIR}/sql

done
