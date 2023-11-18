import cx_Oracle
from influxdb import InfluxDBClient
import os
import argparse

def main():
    parser = argparse.ArgumentParser(description='Script to execute SQL queries and insert results into InfluxDB.')
    parser.add_argument('--influxdb-host', required=True, help='InfluxDB host')
    parser.add_argument('--influxdb-port', required=True, help='InfluxDB port')
    parser.add_argument('--influxdb-database', required=True, help='InfluxDB database name')
    parser.add_argument('--sql-directory', required=True, help='Directory containing SQL files')
    parser.add_argument('--sid', action='store_true', help='Oracle SID')
    parser.add_argument('--verbose', action='store_true', help='Enable verbose mode')

    args = parser.parse_args()

    # Connexion à la base de données Oracle
    if args.verbose:
        print(f"Connecting to Oracle database at / as sysdba ")
    os.environ["ORACLE_SID"] = args.sql_directory
    oracle_connection = cx_Oracle.connect( '/', mode = cx_Oracle.SYSDBA)
    oracle_cursor = oracle_connection.cursor()
    oracle_cursor.execute("select HOST_NAME, INSTANCE_NAME from v$instance")
    for row in oracle_cursor:
        host_name = row[0]
        instance_name = row[1]
    oracle_cursor.close()

    oracle_cursor = oracle_connection.cursor()

    # Liste des fichiers SQL dans le répertoire
    sql_files = [f for f in os.listdir(args.sql_directory) if f.endswith(".sql")]

    # Itération sur chaque fichier SQL
    for sql_file in sql_files:
        if args.verbose:
            print(f"Processing SQL file: {sql_file}")

        sql_file_path = os.path.join(args.sql_directory, sql_file)

        # Lecture de la requête SQL depuis le fichier
        with open(sql_file_path, 'r') as file:
            query = file.read()

        # Extrait le nom du fichier sans l'extension
        measurement_name = os.path.splitext(os.path.basename(sql_file_path))[0]

        # Exécution de la requête Oracle
        if args.verbose:
            print(f"Executing Oracle query for measurement: {measurement_name}")
        oracle_cursor.execute(query)

        # Récupération des noms des colonnes
        column_names = [d[0] for d in oracle_cursor.description]

        # Récupération de toutes les lignes
        results = oracle_cursor.fetchall()

        # Création des données à injecter dans InfluxDB
        data = []

        # Itération sur chaque ligne
        for result in results:
            data.append(
                {
                    "measurement": measurement_name,
                    "tags": {
                        "host_name": host_name,
                        "instance_name": instance_name
                    },
                    "fields": {column_names[i]: result[i] for i in range(len(column_names))}
                }
            )

        # Connexion à InfluxDB
        if args.verbose:
            print(f"Connecting to InfluxDB at {args.influxdb_host}:{args.influxdb_port} for database: {args.influxdb_database}")
        influxdb_client = InfluxDBClient(args.influxdb_host, args.influxdb_port, database=args.influxdb_database)

        # Écriture des données dans InfluxDB
        if args.verbose:
            print(f"Writing data to InfluxDB for measurement: {measurement_name}")
        influxdb_client.write_points(data)

        # Fermeture de la connexion InfluxDB
        influxdb_client.close()

    # Fermeture de la connexion Oracle
    oracle_cursor.close()
    oracle_connection.close()

if __name__ == "__main__":
    main()

