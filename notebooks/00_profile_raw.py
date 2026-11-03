from pathlib import Path

import pandas as pd

# Where the raw files are
RAW_DIR = Path(__file__).resolve().parent.parent / "data" / "raw"

# Load both files
casino = pd.read_csv(RAW_DIR / "Online_casino_DIB.csv")
sports = pd.read_csv(RAW_DIR / "Online_sports_DIB.csv")

# Check the number of rows
print("Casino rows:", len(casino), "(article says 138,928)")
print("Sports rows:", len(sports), "(article says 447,853)")

# Check the column names
print("Casino columns:", list(casino.columns))
print("Sports columns:", list(sports.columns))


# Exact values in TransactionType
print("\nCasino TransactionType:")
print(casino["TransactionType"].value_counts())
print("\nSports TransactionType:")
print(sports["TransactionType"].value_counts())

# Exact values in Status
print("\nCasino Status:")
print(casino["Status"].value_counts())
print("\nSports Status:")
print(sports["Status"].value_counts())

# How type and status combine
print("\nCasino TransactionType x Status:")
print(pd.crosstab(casino["TransactionType"], casino["Status"]))
print("\nSports TransactionType x Status:")
print(pd.crosstab(sports["TransactionType"], sports["Status"]))


# Convert the timestamp text into real dates (in UTC)
casino["ts_utc"] = pd.to_datetime(casino["ReqTimeUTC"], utc=True)
sports["ts_utc"] = pd.to_datetime(sports["ReqTimeUTC"], utc=True)

# Show what the raw timestamp text looks like
print("\nExample raw timestamps:", casino["ReqTimeUTC"].head(3).tolist())

# Earliest and latest transaction in each file
print("\nCasino dates:", casino["ts_utc"].min(), "to", casino["ts_utc"].max())
print("Sports dates:", sports["ts_utc"].min(), "to", sports["ts_utc"].max())
print("(article says 2019-03-01 to 2020-02-29)")


# Summary of transaction amounts (USD)
print("\nCasino amounts:")
print(casino["TransactionAmount"].describe())
print("\nSports amounts:")
print(sports["TransactionAmount"].describe())

# Look for impossible or suspicious amounts
print("\nCasino zero amounts:", (casino["TransactionAmount"] == 0).sum())
print("Casino negative amounts:", (casino["TransactionAmount"] < 0).sum())
print("Sports zero amounts:", (sports["TransactionAmount"] == 0).sum())
print("Sports negative amounts:", (sports["TransactionAmount"] < 0).sum())

# Columns we want to see for each transaction
cols = ["ReqTimeUTC", "TransactionType", "TransactionAmount", "Status", "AccountIdentifier"]

# The 10 largest sports transactions
print("\nSports: 10 largest transactions")
print(sports.nlargest(10, "TransactionAmount")[cols])

# The 10 largest casino transactions
print("\nCasino: 10 largest transactions")
print(casino.nlargest(10, "TransactionAmount")[cols])

# How many sports transactions are under $1, and of which type
small = sports[sports["TransactionAmount"] < 1]
print("\nSports transactions under $1:", len(small))
print(small["TransactionType"].value_counts())

# Number of unique customers per brand
print("\nCasino customers:", casino["AccountIdentifier"].nunique(), "(article says 2,286)")
print("Sports customers:", sports["AccountIdentifier"].nunique(), "(article says 5,580)")

# Month in which each customer first appears (Pacific time)
for name, df in [("Casino", casino), ("Sports", sports)]:
    df["ts_pacific"] = df["ts_utc"].dt.tz_convert("America/Los_Angeles")
    first_seen = df.groupby("AccountIdentifier")["ts_pacific"].min()
    print(f"\n{name}: customers by month first seen")
    print(first_seen.dt.strftime("%Y-%m").value_counts().sort_index())

    # Customers with no approved transaction at all
for name, df in [("Casino", casino), ("Sports", sports)]:
    approved = df[df["Status"] == "APPROVED"]
    all_ids = set(df["AccountIdentifier"])
    approved_ids = set(approved["AccountIdentifier"])
    never_approved = all_ids - approved_ids
    print(f"\n{name}: customers with NO approved transaction:", len(never_approved))

    # Customers who never made an approved deposit into gambling
    deposits = approved[approved["TransactionType"] == "LOYALTYCARDDEBIT"]
    no_deposit = all_ids - set(deposits["AccountIdentifier"])
    print(f"{name}: customers with NO approved deposit into gambling:", len(no_deposit))

    # Test: article filter = at least one approved deposit into gambling
#       AND only activity up to 29 Feb 2020 (Pacific time)
cutoff = pd.Timestamp("2020-03-01", tz="America/Los_Angeles")

for name, df, article_count in [("Casino", casino, 2286), ("Sports", sports, 5580)]:
    # Keep only transactions before 1 March 2020 (Pacific)
    in_window = df[df["ts_pacific"] < cutoff]

    # Keep only customers with an approved deposit into gambling in that window
    deposits = in_window[
        (in_window["Status"] == "APPROVED")
        & (in_window["TransactionType"] == "LOYALTYCARDDEBIT")
    ]
    kept = deposits["AccountIdentifier"].nunique()
    print(f"\n{name}: customers after both filters:", kept, f"(article says {article_count})")