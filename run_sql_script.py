from pathlib import Path

from oracle_connection import get_oracle_connection


PROJECT_ROOT = Path(__file__).resolve().parent
SQL_FILE = PROJECT_ROOT / "sql" / "01_create_tables.sql"


def remove_single_line_comments(sql_text):
    """Removes lines starting with -- comments."""

    cleaned_lines = []

    for line in sql_text.splitlines():
        stripped_line = line.strip()

        if stripped_line.startswith("--"):
            continue

        cleaned_lines.append(line)

    return "\n".join(cleaned_lines)


def split_sql_statements(sql_text):
    """
    Splits this project SQL file into separate statements.

    Our current table-creation file contains normal CREATE TABLE
    and CREATE INDEX commands only, so splitting by semicolon is safe.
    """

    statements = []

    for statement in sql_text.split(";"):
        cleaned_statement = statement.strip()

        if cleaned_statement:
            statements.append(cleaned_statement)

    return statements


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
            "No SQL statements were found in 01_create_tables.sql."
        )

    connection = None

    try:
        connection = get_oracle_connection()

        with connection.cursor() as cursor:
            print(
                "Connected to Oracle. "
                f"Executing {len(statements)} SQL statements.\n"
            )

            for statement_number, statement in enumerate(
                statements,
                start=1
            ):
                first_line = statement.splitlines()[0].strip()

                try:
                    cursor.execute(statement)

                    print(
                        f"[{statement_number}/{len(statements)}] "
                        f"Completed: {first_line}"
                    )

                except Exception as error:
                    error_text = str(error)

                    # ORA-00955: table/index name already exists.
                    # ORA-01408: Oracle already has an index
                    # on the same column list.
                    if (
                        "ORA-00955" in error_text
                        or "ORA-01408" in error_text
                    ):
                        print(
                            f"[{statement_number}/{len(statements)}] "
                            f"Skipped (already exists): {first_line}"
                        )
                        continue

                    print(
                        f"\nFAILED at statement "
                        f"{statement_number}/{len(statements)}"
                    )
                    print(f"Statement starts with: {first_line}")
                    print("\nOracle error:")
                    print(error)

                    raise

        print("\nAll Oracle tables and indexes were created successfully.")

    finally:
        if connection:
            connection.close()
            print("Oracle connection closed.")


if __name__ == "__main__":
    main()

    