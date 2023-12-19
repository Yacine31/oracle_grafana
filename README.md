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
/usr/bin/python3 ${SCRIPT_DIR}/getMetrics.py --sid $sid --verbose --influxdb-host ${INFLUX_HOST} --influxdb-port ${INFLUX_PORT} --influxdb-database ${INFLUX_DB} --sql-directory ${SCRIPT_DIR}/sql
```

Pour le mettre dans cron pour une exécution toutes les 5 minutes : 
```bash
*/5 * * * * sh /home/oracle/oracle_grafana/getMetrics.sh
```
## Pour ajouter de nouvelles fonctionnalités : 
- créer un script sql et le mettre dans le répertoire sql
- le nom du script va correspond à la "table" créée dans influxdb
- créer un nouveau dashboard ou un nouveau bloc dans un dashboard grafana existant

## déploiement par Ansible : 
Aller dans le répertoire ansible :

Le fichier host.txt doit contenir le nom ou l'ip du serveur cible ou des serveurs cibles :
```ini
[all]
srv-oracle-1
srv-oracle-2
srv-oracle-3
```

Déploiement : le mot de passe demandé est celui du compte "oracle"

```bash
ansible-playbook -v -i host.txt install_oracle_grafana.yml --ask-pass -u oracle -e 'ansible_python_interpreter=/usr/bin/python3' -e 'ansible_python_interpreter=/usr/bin/python3'
```
