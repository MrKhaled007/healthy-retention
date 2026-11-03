\# Decisions and findings



\## Phase 0 – Data profiling (3 Nov 2026)



Source: Ghaharian et al. (2023), Data in Brief, DOI 10.17632/9j5gcygnwg.1 (CC BY 4.0)



\### Verified against the article

\- Row counts match: casino 138,928, sports 447,853.

\- Five columns match: ReqTimeUTC, TransactionType, TransactionAmount, Status, AccountIdentifier.

\- Each row is one transaction. The Mendeley page says "each row represents a unique customer"; this is wrong.

\- Status values: APPROVED, DECLINED.

\- No zero or negative amounts.



\### Findings

\- Casino has no ACH (bank transfer) funding; only sports does.

\- Most declines happen at wallet funding by card: casino 8.2%, sports 3.1%.

\- Casino players withdraw far less often than sports players

&#x20; (about 1 withdrawal per 18 deposits vs 1 per 7).

\- The 10 largest sports transactions ($52,915–$545,700) were all DECLINED

&#x20; deposits into gambling. No money moved.

\- One casino customer made repeated withdrawals just under $10,000.

\- Sports has 1,738 transactions under $1, mostly deposits and withdrawals.

\- The extract runs from 1 Mar 2019 to 1 Mar 2020 in Pacific time

&#x20; (08:00 UTC boundaries), one day more than the article states.

\- March 2019 has 4–5x more first-seen customers than later months:

&#x20; these are existing players, not new ones.

\- Sports shows seasonality: a rise in September and a large spike in November.

\- 50 casino and 24 sports customers had every transaction declined.

\- The article's customer counts (2,286 / 5,580) are reproduced exactly by keeping

&#x20; customers with at least one approved deposit into gambling, up to 29 Feb 2020 (Pacific).



\### Decisions

1\. Days and months are defined in Pacific time (how the data was cut).

2\. Analysis window: 1 Mar 2019 – 29 Feb 2020 (Pacific). Rows on 1 Mar 2020 are excluded.

3\. Money totals use APPROVED transactions only. Declined transactions are counted

&#x20;  as friction events but their amounts are never summed.

4\. Typical amounts are reported as medians, not averages (data is heavily skewed).

5\. Small amounts (under $1) are kept.

6\. Player key = brand + AccountIdentifier (IDs may repeat across brands).

7\. A "new player" is first seen on or after 1 May 2019 (Pacific).

&#x20;  Players first seen in March–April 2019 are "existing".

8\. The deposit journey starts at "tried to fund", so players who never succeed are counted.

9\. Retention compares only players with the same amount of follow-up time.

10\. Time-of-day markers use each brand's local time (casino: US Eastern, sports: US Pacific).



\### Open questions

\- Why does sports have a large spike in new players in November 2019?

\- Are the repeated withdrawals just under $10,000 caused by a per-transaction limit?

\- Why are some deposits into gambling declined? (insufficient wallet balance?)

