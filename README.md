# oracle_grafana
 monitorin Oracle avec Grafana/Telegraf/Influxdb

Pour collecter les infos : 

Se connecter avec le compte oracle :

wget https://bootstrap.pypa.io/pip/3.6/get-pip.py -O get-pip.py
python3 get-pip.py
pip install cx-Oracle
pip install influxdb

git clone https://github.com/Yacine31/oracle_grafana
cd oracle_grafana
sh getMetrics.sh

Il appelle le script : 
	getMetrics.py --sid ORCL --influxdb-host srvorap --influxdb-port 8086 --influxdb-database influx --sql-directory sql



=====
Pour ajouter de nouvelles fonctionnalité : 
- créer un script sql et le mettre dans le répertoire sql
- le nom du script va correspond à la "table" créée dans influxdb
- créer un nouveau dashboard ou un nouveau bloc dans un dashboard grafana existant


