# oracle_grafana
monitoring Oracle avec Grafana/Telegraf/Influxdb

## Pour collecter les infos : 

Se connecter avec le compte oracle :

```bash
wget https://bootstrap.pypa.io/pip/3.6/get-pip.py -O get-pip.py
python3 get-pip.py
pip install cx-Oracle
pip install influxdb
```

```bash
git clone https://github.com/Yacine31/oracle_grafana
cd oracle_grafana
sh getMetrics.sh
```

Il appelle le script : 
```bash
	getMetrics.py --sid ORCL --influxdb-host srvorap --influxdb-port 8086 --influxdb-database influx --sql-directory sql
```

Pour l'exécuter dans une boucle (dans screen) :
```bash
while true; do sh getMetrics.sh; echo "---- $(date) ----"; sleep 60; done
```

## Pour ajouter de nouvelles fonctionnalité : 
- créer un script sql et le mettre dans le répertoire sql
- le nom du script va correspond à la "table" créée dans influxdb
- créer un nouveau dashboard ou un nouveau bloc dans un dashboard grafana existant


