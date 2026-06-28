from pathlib import Path
import sys


# Lets this file inside src/ import oracle_connection.py
PROJECT_ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(PROJECT_ROOT))

from oracle_connection import get_oracle_connection


SQL_FILE = (
    PROJECT_ROOT
    / "sql"
    / "02_data_quality_checks.sql"
)


def remove_single_line_comments(sql_text):
    """Removes lines that start with -- comments."""

    cleaned_lines = []

    for line in sql_text.splitlines():
        if line.strip().startswith("--"):
            continue

        cleaned_lines.append(line)

    return "\n".join(cleaned_lines)


def split_sql_statements(sql_text):
    """Splits this read-only SQL file into individual SELECT queries."""

    statements = []

    for statement in sql_text.split(";"):
        cleaned_statement = statement.strip()

        if cleaned_statement:
            statements.append(cleaned_statement)

    return statements


def format_value(value):
    """Makes NULL values easier to read in PowerShell."""

    if value is None:
        return "NULL"

    return str(value)


def print_result_table(column_names, rows):
    """Prints a simple readable result table in PowerShell."""

    if not rows:
        print("Result: 0 rows returned.")
        return

    text_rows = [
        [format_value(value) for value in row]
        for row in rows
    ]

    column_widths = []

    for column_index, column_name in enumerate(column_names):
        widest_value = max(
            len(column_name),
            *[
                len(row[column_index])
                for row in text_rows
            ]
        )

        column_widths.append(widest_value)

    header = " | ".join(
        column_name.ljust(column_widths[index])
        for index, column_name in enumerate(column_names)
    )

    separator = "-+-".join(
        "-" * column_widths[index]
        for index in range(len(column_names))
    )

    print(header)
    print(separator)

    for row in text_rows:
        print(
            " | ".join(
                row[index].ljust(column_widths[index])
                for index in range(len(row))
            )
        )

    print(f"Result: {len(rows):,} row(s) returned.")


def main():
    if not SQL_FILE.exists():
        raise FileNotFoundError(
            f"SQL file was not found:\n{SQL_FILE}"
        )

    sql_text = SQL_FILE.read_text(encoding="utf-8")
    sql_text = remove_single_line_comments(sql_text)

    statements = split_sql_statements(sql_text)

    if not statements:
        raise ValueError(
            "No SQL queries were found in 02_data_quality_checks.sql."
        )

    connection = None

    try:
        connection = get_oracle_connection()

        with connection.cursor() as cursor:
            print(
                "Connected to Oracle. "
                f"Running {len(statements)} data-quality checks.\n"
            )

            for number, statement in enumerate(
                statements,
                start=1
            ):
                print("=" * 80)
                print(f"CHECK {number} OF {len(statements)}")
                print("=" * 80)

                cursor.execute(statement)

                column_names = [
                    column[0]
                    for column in cursor.description
                ]

                rows = cursor.fetchall()

                print_result_table(
                    column_names=column_names,
                    rows=rows
                )

                print()

        print("All data-quality checks finished successfully.")

    finally:
        if connection:
            connection.close()
            print("Oracle connection closed.")


if __name__ == "__main__":
    main()