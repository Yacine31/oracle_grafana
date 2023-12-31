import cx_Oracle
from influxdb_client import InfluxDBClient
from influxdb_client.client.write_api import SYNCHRONOUS
import os
import argparse

def main():
    parser = argparse.ArgumentParser(description='Script to execute SQL queries and insert results into InfluxDB.')
    parser.add_argument('--influxdb-host', required=True, help='InfluxDB host')
    parser.add_argument('--influxdb-port', required=True, help='InfluxDB port')
    parser.add_argument('--influxdb-token', required=True, help='InfluxDB token')
    parser.add_argument('--influxdb-org', required=True, help='InfluxDB organization')
    parser.add_argument('--influxdb-bucket', required=True, help='InfluxDB bucket')
    parser.add_argument('--sql-directory', required=True, help='Directory containing SQL files')
    parser.add_argument('--sid', required=True, help='Oracle SID')
    parser.add_argument('--verbose', action='store_true', help='Enable verbose mode')

    args = parser.parse_args()

    # Connexion à la base de données Oracle
    if args.verbose:
        print(f"Connecting to Oracle database at / as sysdba ")
    os.environ["ORACLE_SID"] = args.sid
    oracle_connection = cx_Oracle.connect('/', mode=cx_Oracle.SYSDBA)
    oracle_cursor = oracle_connection.cursor()
    oracle_cursor.execute("select HOST_NAME, INSTANCE_NAME from v$instance")
    for row in oracle_cursor:
        host_name = row[0]
        instance_name = row[1]
    oracle_cursor.close()

    oracle_cursor = oracle_connection.cursor()

    # Liste des fichiers SQL dans le répertoire
    sql_files = [f for f in os.listdir(args.sql_directory) if f.endswith(".sql")]

    # Connexion à InfluxDB
    influxdb_client = InfluxDBClient(url=f"http://{args.influxdb_host}:{args.influxdb_port}", token=args.influxdb_token, org=args.influxdb_org)

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
        # try : pour passer des requêtes sur les bases standby
        # en cas d'erreur, on passe à la requêtes suivante
        try:
            oracle_cursor.execute(query)
        except cx_Oracle.DatabaseError as e:
            print(f"Error executing Oracle query: {e}")
            # Passer à l'occurrence suivante de la boucle
            continue

        # Récupération des noms des colonnes
        column_names = [d[0] for d in oracle_cursor.description]

        # Récupération de toutes les lignes
        results = oracle_cursor.fetchall()

        # Création des données à injecter dans InfluxDB
        data = []

        if measurement_name=='SGAstat':
            # Cas des données pour les tablespaces
            for result in results:
                data_point = {
                    "measurement": measurement_name,
                    "tags": {
                        "host_name": host_name,
                        "instance_name": instance_name,
                        "component": result[column_names.index('COMPONENT')]
                    },
                    "fields": {
                        "size_mb": float(result[column_names.index('SIZE_MB')])
                    }
                }
                data.append(data_point)
        elif measurement_name=='DatafileInfo':
            # Cas des données pour les datafile
            for result in results:
                data_point = {
                    "measurement": measurement_name,
                    "tags": {
                        "host_name": host_name,
                        "instance_name": instance_name,
                        "file_name": result[column_names.index('FILE_NAME')] 
                    },
                    "fields": {
                        "file_size": float(result[column_names.index('FILE_SIZE')]),
                        "maxsize": float(result[column_names.index('MAXSIZE')]),
                        "space_used": float(result[column_names.index('SPACE_USED')]),
                        "space_free": float(result[column_names.index('SPACE_FREE')]),
                        "percent_used": float(result[column_names.index('PERCENT_USED')])
                    }
                }
                data.append(data_point)
        elif measurement_name=='AlertLog':
            # Cas des données pour les erreurs alerlog
            for result in results:
                data_point = {
                    "measurement": measurement_name,
                    "tags": {
                        "host_name": host_name,
                        "instance_name": instance_name
                    },
                    "fields": {
                        "message_text": result[column_names.index('MESSAGE_TEXT')]
                    }
                }
                data.append(data_point)
        elif measurement_name=='SchemaSize':
            # Cas des données pour les SchemaSize
            for result in results:
                data_point = {
                    "measurement": measurement_name,
                    "tags": {
                        "host_name": host_name,
                        "instance_name": instance_name,
                        "owner": result[column_names.index('OWNER')]
                    },
                    "fields": {
                        "schema_size": int(result[column_names.index('SCHEMA_SIZE')]),
                        "default_tablespace": result[column_names.index('DEFAULT_TABLESPACE')]
                    }
                }
                data.append(data_point)
        elif measurement_name=='Sessions':
            # Cas des données pour les Sessions
            for result in results:
                data_point = {
                    "measurement": measurement_name,
                    "tags": {
                        "host_name": host_name,
                        "instance_name": instance_name,
                        "username": result[column_names.index('USERNAME')],
                        "machine": result[column_names.index('MACHINE')],
                        "program": result[column_names.index('PROGRAM')]
                    },
                    "fields": {
                        "session_count": int(result[column_names.index('SESSION_COUNT')])
                    }
                }
                data.append(data_point)
        elif measurement_name=='TablespaceDetail':
            # Cas des données pour les tablespaces avec detail
            for result in results:
                data_point = {
                    "measurement": measurement_name,
                    "tags": {
                        "host_name": host_name,
                        "instance_name": instance_name,
                        "tablespace_name": result[column_names.index('TABLESPACE_NAME')],
                    },
                    "fields": {
                        "megs_alloc": float(result[column_names.index('MEGS_ALLOC')]),
                        "megs_used": float(result[column_names.index('MEGS_USED')]),
                        "megs_free": float(result[column_names.index('MEGS_FREE')]),
                        "Max": float(result[column_names.index('MAX')]),
                        "Pct_Used_Max": float(result[column_names.index('PCT_USED_MAX')])
                    }
                }
                data.append(data_point)
        elif measurement_name=='DatabaseSizeDetail':
            # Cas des données pour les tablespaces avec detail
            for result in results:
                data_point = {
                    "measurement": measurement_name,
                    "tags": {
                        "host_name": host_name,
                        "instance_name": instance_name,
                        "file_type": result[column_names.index('FILE_TYPE')],
                    },
                    "fields": {
                        "bytes": float(result[column_names.index('BYTES')])
                    }
                }
                data.append(data_point)
        elif measurement_name=='TablespaceInfo':
            # Cas des données pour les tablespaces
            for result in results:
                data_point = {
                    "measurement": measurement_name,
                    "tags": {
                        "host_name": host_name,
                        "instance_name": instance_name,
                        "tablespace_name": result[column_names.index('TABLESPACE_NAME')],
                        "contents": result[column_names.index('CONTENTS')]
                    },
                    "fields": {
                        "allocated": float(result[column_names.index('MEGS_ALLOC')]),
                        "used": float(result[column_names.index('MEGS_USED')]),
                        "free": float(result[column_names.index('MEGS_FREE')]),
                        "max_size": float(result[column_names.index('MAX')]),
                        "pct_used": float(result[column_names.index('PCT_USED')]),
                        "pct_free": float(result[column_names.index('PCT_FREE')]),
                        "pct_used_max": float(result[column_names.index('PCT_USED_MAX')]),
                        "pct_free_max": float(result[column_names.index('PCT_FREE_MAX')]),
                    }
                }
                data.append(data_point)
        elif measurement_name=='WaitclassMetrics':
            # Cas des données pour les WaitclassMetrics
            for result in results:
                data_point = {
                    "measurement": measurement_name,
                    "tags": {
                        "host_name": host_name,
                        "instance_name": instance_name,
                        "wait_class": result[column_names.index('WAIT_CLASS')],
                    },
                    "fields": {
                        "min_value": float(result[column_names.index('MIN_VALUE')]),
                        "avg_value": float(result[column_names.index('AVG_VALUE')]),
                        "max_value": float(result[column_names.index('MAX_VALUE')])
                    }
                }
                data.append(data_point)
        elif measurement_name=='AlertLog_Count':
            # Cas des données pour les AlertLog_Count
            for result in results:
                data_point = {
                    "measurement": measurement_name,
                    "tags": {
                        "host_name": host_name,
                        "instance_name": instance_name,
                        "date_jour": result[column_names.index('DATE_JOUR')],
                    },
                    "fields": {
                        "nb_erreurs": result[column_names.index('NB_ERREURS')]
                    }
                }
                data.append(data_point)
        else:
            # Itération sur chaque ligne
            for result in results:
                data_point = {
                    "measurement": measurement_name,
                    "tags": {
                        "host_name": host_name,
                        "instance_name": instance_name
                    },
                    "fields": {column_names[i]: float(result[i]) if isinstance(result[i], int) else result[i] for i in range(len(column_names))}
                    # "fields": {column_names[i]: result[i] for i in range(len(column_names))}
                }
                data.append(data_point)

        # Affichage du dictionnaire complet après la boucle
        print("Data Points:")
        for data_point in data:
           print(data_point)
        # fin ajout debug

        # Écriture des données dans InfluxDB
        if args.verbose:
            print(f"Writing data to InfluxDB for measurement: {measurement_name}")
        with influxdb_client.write_api(write_options=SYNCHRONOUS) as write_api:
            write_api.write(bucket=args.influxdb_bucket, record=data)

        # Fermeture de la connexion InfluxDB

    influxdb_client.__del__()

    # Fermeture de la connexion Oracle
    oracle_cursor.close()
    oracle_connection.close()

if __name__ == "__main__":
    main()
