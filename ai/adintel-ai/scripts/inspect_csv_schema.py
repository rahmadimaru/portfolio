from pathlib import Path

import pandas as pd


PROJECT_ROOT = Path(__file__).resolve().parents[1]
DATA_DIR = PROJECT_ROOT / "data" / "synthetic"


def inspect_csv(file_path: Path) -> None:
    print("=" * 100)
    print(f"FILE: {file_path.name}")
    print("=" * 100)

    try:
        df = pd.read_csv(file_path)
    except Exception as exc:
        print(f"FAILED TO READ FILE: {file_path}")
        print(f"ERROR: {exc}")
        return

    print("\nROW COUNT:")
    print(len(df))

    print("\nCOLUMNS:")
    for col in df.columns:
        print(f"- {col}")

    print("\nPANDAS DTYPES:")
    print(df.dtypes)

    print("\nNULL COUNT:")
    print(df.isna().sum())

    print("\nSAMPLE 3 ROWS:")
    if len(df) > 0:
        print(df.head(3).to_string(index=False))
    else:
        print("No rows found.")

    print("\n")


def main() -> None:
    if not DATA_DIR.exists():
        raise FileNotFoundError(
            f"Data directory not found: {DATA_DIR}\n"
            "Please make sure synthetic CSV files are located in data/synthetic/"
        )

    csv_files = sorted(DATA_DIR.glob("*.csv"))

    if not csv_files:
        raise FileNotFoundError(
            f"No CSV files found in: {DATA_DIR}"
        )

    print(f"Inspecting CSV files in: {DATA_DIR}")
    print(f"Found {len(csv_files)} CSV file(s).")

    for file_path in csv_files:
        inspect_csv(file_path)

    print("=" * 100)
    print("CSV schema inspection completed.")
    print("=" * 100)


if __name__ == "__main__":
    main()