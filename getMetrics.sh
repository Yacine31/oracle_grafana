# Récupération des variables d'environnement
export SCRIPTS_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

# Nom du fichier .env
ENV_FILE=${SCRIPTS_DIR}"/.env"

# Vérifier si le fichier .env existe
if [ ! -f "$ENV_FILE" ]; then
    echo "Erreur : Le fichier $ENV_FILE n'existe pas."
    echo "Erreur : Impossible de charger les variables d'environnement."
    exit 1
fi

# Charger les variables d'environnement depuis le fichier .env
source "$ENV_FILE"

# mise à jour des scripts depuis le dépôt git
cd ${SCRIPTS_DIR}
git pull

# on boucle sur toutes les bases ouvertes pour envoyer les métriques ver influxdb
for sid in $(ps -eaf | grep pmon | egrep -v 'grep|\+ASM|\+APX' | cut -d '_' -f3)
do
        export ORACLE_SID=$sid
        export ORACLE_HOME=$(cat /etc/oratab | grep "^$sid:" | cut -d: -f2)
        export LD_LIBRARY_PATH=$ORACLE_HOME/lib

        /usr/bin/python3 ${SCRIPTS_DIR}/getMetrics.py --sid $sid --verbose --influxdb-host ${INFLUX_HOST} --influxdb-port ${INFLUX_PORT} --influxdb-database ${INFLUX_DB}  --sql-directory ${SCRIPTS_DIR}/sql

done
