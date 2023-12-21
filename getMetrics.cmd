@echo on

setlocal enabledelayedexpansion

for /f "tokens=*" %%r in ('net start ^| find /i "OracleService"') do (
    set "ORACLE_SID=%%r"
    set "ORACLE_SID=!ORACLE_SID:~13!"
    set ORACLE_HOME=C:\app\product\12.2.0\dbhome_1
    set LD_LIBRARY_PATH=$ORACLE_HOME\lib

    set SCRIPT_DIR=c:\oracle_grafana
    git pull

    REM envoyer les données vers l'environnement de prod sur la VM grafana
    set INFLUX_HOST=192.168.31.3
    set INFLUX_PORT=8086
    set INFLUX_DB=telegraf

    /usr/bin/python !SCRIPT_DIR!/getMetrics.py --sid !ORACLE_SID! --verbose --influxdb-host !INFLUX_HOST! --influxdb-port !INFLUX_PORT! --influxdb-database !INFLUX_DB!  --sql-directory !SCRIPT_DIR!/sql
)
