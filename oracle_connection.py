import json
from pathlib import Path

import oracledb


def get_oracle_connection():
    """
    Reads Oracle credentials from config/db_config.json
    and returns an open Oracle database connection.
    """

    project_root = Path(__file__).resolve().parent.parent
    config_path = project_root / "config" / "db_config.json"

    if not config_path.exists():
        raise FileNotFoundError(
            f"Configuration file not found: {config_path}"
        )

    with open(config_path, "r", encoding="utf-8") as file:
        config = json.load(file)

    required_fields = [
        "host",
        "port",
        "service_name",
        "username",
        "password"
    ]

    missing_fields = [
        field for field in required_fields
        if not config.get(field)
    ]

    if missing_fields:
        raise ValueError(
            f"Missing fields in db_config.json: {', '.join(missing_fields)}"
        )

    dsn = oracledb.makedsn(
        host=config["host"],
        port=int(config["port"]),
        service_name=config["service_name"]
    )

    connection = oracledb.connect(
        user=config["username"],
        password=config["password"],
        dsn=dsn
    )

    return connection


if __name__ == "__main__":
    connection = None

    try:
        connection = get_oracle_connection()

        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT
                    USER AS connected_user,
                    SYS_CONTEXT('USERENV', 'DB_NAME') AS database_name,
                    SYS_CONTEXT('USERENV', 'SERVICE_NAME') AS service_name
                FROM dual
            """)

            user, database, service = cursor.fetchone()

            print("Connection successful.")
            print(f"User: {user}")
            print(f"Database: {database}")
            print(f"Service: {service}")

    except Exception as error:
        print("Connection failed:")
        print(error)

    finally:
        if connection:
            connection.close()