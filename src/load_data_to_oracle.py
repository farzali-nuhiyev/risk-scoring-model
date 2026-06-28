import argparse
import csv
import sys
from datetime import datetime
from decimal import Decimal, InvalidOperation
from pathlib import Path


# Allows this file inside src/ to use oracle_connection.py
# from the main project folder.
PROJECT_ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(PROJECT_ROOT))

from oracle_connection import get_oracle_connection


RAW_DATA_FOLDER = PROJECT_ROOT / "data" / "raw"
BATCH_SIZE = 1_000


# This order matters because later tables depend on earlier tables.
LOAD_PLAN = [
    ("RS_CUSTOMERS", "rs_customers_base.csv"),
    ("RS_CONTRACTS", "rs_contracts_base.csv"),
    ("RS_MKR_MASTER", "rs_mkr_master_base.csv"),
    ("RS_APPLICATIONS", "rs_applications_base.csv"),
    ("RS_MKR_LIABILITIES", "rs_mkr_liabilities_base.csv"),
    ("RS_MKR_LIABILITY_HISTORY", "rs_mkr_liability_history_base.csv"),
    ("RS_MKR_INQUIRY_HISTORY", "rs_mkr_inquiry_history_base.csv"),
    ("RS_CONTRACT_CURRENT", "rs_contract_current_base.csv"),
    (
        "RS_CONTRACT_PERFORMANCE_OUTCOME",
        "rs_contract_performance_outcome_base.csv"
    ),
]


DATE_FORMATS = [
    "%Y-%m-%d",
    "%Y-%m",       # Month-only dates become the 1st day of that month
    "%d-%b-%y",
    "%d-%b-%Y",
]

TIMESTAMP_FORMATS = [
    "%Y-%m-%d %H:%M:%S",
    "%Y-%m-%dT%H:%M:%S",
    "%Y-%m-%d",
]


def parse_date(value):
    """Converts text to a Python date."""

    for date_format in DATE_FORMATS:
        try:
            return datetime.strptime(
                value,
                date_format
            ).date()
        except ValueError:
            continue

    raise ValueError(
        f"Cannot convert this value to DATE: {value}"
    )


def parse_timestamp(value):
    """Converts text to a Python datetime."""

    for timestamp_format in TIMESTAMP_FORMATS:
        try:
            return datetime.strptime(
                value,
                timestamp_format
            )
        except ValueError:
            continue

    raise ValueError(
        f"Cannot convert this value to TIMESTAMP: {value}"
    )


def convert_value(value, oracle_data_type):
    """
    Converts CSV text into a Python value that Oracle understands.
    Blank values become NULL.
    """

    cleaned_value = (value or "").strip()

    if cleaned_value == "":
        return None

    data_type = oracle_data_type.upper()

    if data_type.startswith("DATE"):
        return parse_date(cleaned_value)

    if data_type.startswith("TIMESTAMP"):
        return parse_timestamp(cleaned_value)

    if data_type in {
        "NUMBER",
        "FLOAT",
        "BINARY_FLOAT",
        "BINARY_DOUBLE"
    }:
        try:
            return Decimal(cleaned_value)
        except InvalidOperation as error:
            raise ValueError(
                f"Cannot convert this value to NUMBER: {cleaned_value}"
            ) from error

    return cleaned_value


def get_table_column_types(cursor, table_name):
    """
    Returns:
    {
        'COLUMN_NAME': 'ORACLE_DATA_TYPE'
    }
    """

    cursor.execute(
        """
        SELECT
            column_name,
            data_type
        FROM user_tab_columns
        WHERE table_name = :table_name
        """,
        table_name=table_name
    )

    return {
        column_name: data_type
        for column_name, data_type in cursor.fetchall()
    }


def get_table_row_count(cursor, table_name):
    """Returns current number of rows in an Oracle table."""

    cursor.execute(
        f"SELECT COUNT(*) FROM {table_name}"
    )

    return cursor.fetchone()[0]


def read_csv_header(csv_file):
    """Reads CSV headers without loading all rows into memory."""

    with open(
        csv_file,
        "r",
        encoding="utf-8-sig",
        newline=""
    ) as file:
        reader = csv.reader(file)
        return next(reader)


def count_csv_rows(csv_file):
    """Counts source rows without storing them in memory."""

    with open(
        csv_file,
        "r",
        encoding="utf-8-sig",
        newline=""
    ) as file:
        return sum(1 for _ in file) - 1


def build_insert_sql(table_name, headers):
    """
    Creates an Oracle INSERT statement using the CSV header order.

    Example:
    INSERT INTO RS_CONTRACTS (ACCOUNT_NUMBER, BRANCH_CODE)
    VALUES (:1, :2)
    """

    columns_sql = ", ".join(headers)

    bind_variables = ", ".join(
        f":{position}"
        for position in range(1, len(headers) + 1)
    )

    return (
        f"INSERT INTO {table_name} ({columns_sql}) "
        f"VALUES ({bind_variables})"
    )


def validate_csv_against_table(
    csv_file,
    table_name,
    table_column_types
):
    """Checks file existence and confirms every CSV field exists in Oracle."""

    if not csv_file.exists():
        raise FileNotFoundError(
            f"CSV file was not found:\n{csv_file}"
        )

    headers = read_csv_header(csv_file)

    unknown_columns = [
        header
        for header in headers
        if header.upper() not in table_column_types
    ]

    if unknown_columns:
        raise ValueError(
            f"{csv_file.name} has columns not found in "
            f"{table_name}: {', '.join(unknown_columns)}"
        )

    return headers


def load_one_table(
    connection,
    table_name,
    file_name
):
    """Loads one CSV into one Oracle table in batches."""

    csv_file = RAW_DATA_FOLDER / file_name

    with connection.cursor() as cursor:
        table_column_types = get_table_column_types(
            cursor,
            table_name
        )

        headers = validate_csv_against_table(
            csv_file=csv_file,
            table_name=table_name,
            table_column_types=table_column_types
        )

        existing_rows = get_table_row_count(
            cursor,
            table_name
        )

        if existing_rows > 0:
            raise ValueError(
                f"{table_name} already contains "
                f"{existing_rows:,} rows. "
                "Stopping to prevent duplicate loading."
            )

        insert_sql = build_insert_sql(
            table_name=table_name,
            headers=headers
        )

        loaded_rows = 0
        batch_rows = []

        with open(
            csv_file,
            "r",
            encoding="utf-8-sig",
            newline=""
        ) as file:
            reader = csv.DictReader(file)

            for row_number, row in enumerate(reader, start=2):
                try:
                    
                    converted_values = []

                    for header in headers:
                        try:
                            converted_value = convert_value(
                                value=row.get(header),
                                oracle_data_type=table_column_types[
                                    header.upper()
                                ]
                            )

                            converted_values.append(converted_value)

                        except Exception as error:
                            raise ValueError(
                                f"Column: {header} | "
                                f"Value: {row.get(header)!r} | "
                                f"Expected Oracle type: "
                                f"{table_column_types[header.upper()]} | "
                                f"{error}"
                            ) from error

                    converted_row = tuple(converted_values)

                    batch_rows.append(converted_row)

                except Exception as error:
                    raise ValueError(
                        f"{file_name}, CSV row {row_number}: {error}"
                    ) from error

                if len(batch_rows) >= BATCH_SIZE:
                    cursor.executemany(
                        insert_sql,
                        batch_rows
                    )

                    loaded_rows += len(batch_rows)
                    batch_rows.clear()

            if batch_rows:
                cursor.executemany(
                    insert_sql,
                    batch_rows
                )

                loaded_rows += len(batch_rows)

    return loaded_rows


def dry_run(connection):
    """Checks all files, headers, existing rows, and source row counts."""

    print("DRY RUN: no data will be inserted.\n")

    with connection.cursor() as cursor:
        for table_name, file_name in LOAD_PLAN:
            csv_file = RAW_DATA_FOLDER / file_name

            table_column_types = get_table_column_types(
                cursor,
                table_name
            )

            headers = validate_csv_against_table(
                csv_file=csv_file,
                table_name=table_name,
                table_column_types=table_column_types
            )

            existing_rows = get_table_row_count(
                cursor,
                table_name
            )

            source_rows = count_csv_rows(csv_file)

            print(f"Table: {table_name}")
            print(f"Source file: {file_name}")
            print(f"CSV columns: {len(headers)}")
            print(f"CSV rows: {source_rows:,}")
            print(f"Rows currently in Oracle: {existing_rows:,}")
            print("-" * 60)

            if existing_rows > 0:
                raise ValueError(
                    f"{table_name} is not empty. "
                    "Dry run stopped to protect against duplicates."
                )

    print("DRY RUN PASSED: all files and Oracle tables are ready.")


def load_all_data(connection):
    """
    Loads every table in one transaction.

    If any table fails, all inserted rows are rolled back.
    """

    print("Starting Oracle data load.\n")

    try:
        for table_name, file_name in LOAD_PLAN:
            print(f"Loading {table_name} from {file_name}...")

            loaded_rows = load_one_table(
                connection=connection,
                table_name=table_name,
                file_name=file_name
            )

            print(
                f"Completed {table_name}: "
                f"{loaded_rows:,} rows inserted.\n"
            )

        connection.commit()

        print("ALL DATA LOADED SUCCESSFULLY.")
        print("Oracle transaction committed.")

    except Exception:
        connection.rollback()

        print("\nLOAD FAILED.")
        print("Oracle transaction rolled back.")
        print("No partial CSV load was kept.")

        raise


def main():
    parser = argparse.ArgumentParser(
        description="Load risk-scoring CSV data into Oracle."
    )

    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Check files and tables without inserting data."
    )

    arguments = parser.parse_args()

    connection = None

    try:
        connection = get_oracle_connection()

        if arguments.dry_run:
            dry_run(connection)
        else:
            load_all_data(connection)

    finally:
        if connection:
            connection.close()
            print("Oracle connection closed.")


if __name__ == "__main__":
    main()