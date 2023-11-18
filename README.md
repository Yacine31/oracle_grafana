# oracle_grafana
 monitorin Oracle avec Grafana/Telegraf/Influxdb

Pour collecter les infos : 

getMetrics.py --sid ORCL --influxdb-host srvorap --influxdb-port 8086 --influxdb-database influx --sql-directory sql

Pour couvrir toutes les bases de ce serveur : utiliser le script getMetrics.sh


