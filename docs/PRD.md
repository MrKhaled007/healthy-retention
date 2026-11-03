\# PRD – Healthy Retention



A player-journey analysis for a Duty of Care market.



\## 1. Problem



Regulated operators in Belgium cannot use bonuses or most advertising, deposits are

capped at €200 per week, and operators have a Duty of Care to detect risky play.

Growth must come from the player journey itself. But not all retention is good

retention: keeping a high-intensity player active is not a success.



\## 2. Business question



Where do players drop off in their deposit journey, why do they leave, and how can

we keep recreational players engaged without retaining at-risk ones?



\## 3. Audience



| Reader | What they need |

|---|---|

| Head Of (player journey area) | Three clear recommendations and the evidence behind them |

| Product Manager | Where the journey breaks and which friction to fix first |

| Responsible Gaming team | How much retained activity comes from high-intensity players |

| Data Engineers | What tables, grain and tests the analysis needs |



\## 4. Data



\*\*Source:\*\* Ghaharian et al. (2023), \*Raw payments transaction data from online casino

players and online sports bettors\*, Mendeley Data, DOI 10.17632/9j5gcygnwg.1.

Licence: CC BY 4.0.



| File | Rows | Brand |

|---|---|---|

| Online\_casino\_DIB.csv | 138,928 | Casino-focused, US East Coast |

| Online\_sports\_DIB.csv | 447,853 | Sports-focused, US West Coast |



\*\*Grain:\*\* one row per payment transaction.

\*\*Period:\*\* 1 Mar 2019 – 29 Feb 2020 (Pacific time) after cleaning.

\*\*Columns:\*\* ReqTimeUTC, TransactionType, TransactionAmount, Status, AccountIdentifier.



\*\*Transaction types:\*\*



| Type | Meaning |

|---|---|

| LOYALTYCARDCREDITCL | Wallet funded by card |

| LOYALTYCARDCREDITACH | Wallet funded by bank transfer (sports only) |

| LOYALTYCARDDEBIT | Deposit into gambling |

| LOYALTYCARDCREDIT | Withdrawal from gambling |



Profiling results and cleaning rules: see `docs/DECISIONS.md`.



\## 5. Scope



\*\*In scope\*\*

\- Deposit journey funnel and drop-offs

\- Monthly retention cohorts for new players

\- Player segments based on payment behaviour

\- Healthy vs high-intensity retention

\- Payment friction (declines and churn)

\- Casino vs sports comparison

\- Early churn proof of concept with a Duty of Care guardrail

\- AI-assisted Power BI reporting proof of concept



\*\*Out of scope\*\*

\- Gameplay, bets and stakes (not in the data)

\- Clickstream or in-app screens (not in the data)

\- Confirmed gambling harm (no clinical labels; "high-intensity" is a proxy)

\- Real-time pipelines and production deployment



\## 6. Analyses



Each analysis follows: written hypothesis → SQL → result → confirmed or rejected.

Hypotheses are written before the query is run and are never edited afterwards.



| # | Question | Starting hypothesis |

|---|---|---|

| 1 | Where does the deposit journey break? | The biggest drop is between the first and second deposit into gambling |

| 2 | How many new players come back in month 2 and 3? | Sports players retain better than casino players |

| 3 | What player types exist? | A small high-intensity segment drives a large share of deposits |

| 4 | How healthy is our retention? | A large share of month-3 activity comes from high-intensity players |

| 5 | Does payment friction drive churn? | Players with a declined first funding attempt churn more |

| 6 | How do casino and sports journeys differ? | Casino players deposit more often in smaller amounts |



\*\*Deposit journey steps:\*\* tried to fund → funded successfully → first deposit into

gambling → second deposit → first withdrawal → active in month 2 → active in month 3.



\## 7. Proofs of concept



\*\*PoC 1 – Early churn model\*\*

Can a simple model predict churn from a player's first 30 days better than an

analyst's rule? Guardrail: check whether the players it would try to keep are

high-intensity. Verdict: adopt, iterate or drop.



\*\*PoC 2 – AI-assisted reporting\*\*

Can Claude generate decision-ready Power BI report pages from a hand-built semantic

model? Record what worked and what had to be fixed. Verdict: adopt, iterate or drop.

Copilot in Power BI was considered but needs a paid Fabric capacity; Claude was

chosen for cost and version control.



\## 8. Stack



| Layer | Tool | Built by |

|---|---|---|

| Profiling and exploration | Python (pandas) | Me |

| Database | PostgreSQL | Me |

| Models, tests, docs | dbt | Me |

| Semantic model and DAX | Power BI on Microsoft Fabric (trial) | Me, by hand |

| Report pages | Power BI (PBIP) | Claude generates 5, I build 1 and edit all |

| Versioning | Git and GitHub | Me |



\## 9. Data model



Star schema:

\- `fct\_transactions`: one row per transaction

\- `fct\_player\_month`: one row per player per month

\- `dim\_player`: one row per player (key = brand + AccountIdentifier)

\- `dim\_brand`: casino, sports

\- `dim\_date`: calendar in Pacific time



\## 10. Power BI report



One report, one semantic model, six pages.



| # | Page | Key visuals | Built by |

|---|---|---|---|

| 1 | Deposit Journey | Funnel chart, drop-off bars | Claude + my edits |

| 2 | Retention | Cohort heatmap, retention curve | Claude + my edits |

| 3 | Segments | Segment bars, frequency vs amount scatter | Claude + my edits |

| 4 | Healthy Retention | Healthy vs high-intensity stacked bars | Claude + my edits |

| 5 | Payment Friction | Churn by number of declines | Claude + my edits |

| 6 | Data Quality | Test results, row counts, known issues | Me, by hand |



Every page has KPI cards and slicers for brand and cohort month.

v1.0 covers the casino brand; v1.1 adds the sports brand (logged in CHANGELOG.md).



\## 11. Deliverables



\- Star schema with dbt tests at every layer

\- Six SQL analyses and a query quality section

\- Power BI report, semantic model document, DAX measures dictionary, CHANGELOG.md

\- 4–5 one-page insight notes (question, hypothesis, finding, why, recommendation, open questions)

\- Memo to the Head Of with three recommendations

\- Data engineer request spec (one page)

\- README: domain primer, ethics note, limitations, "what I'd need to learn on day one"

\- FEEDBACK.md (real reviewers only)

\- DECISIONS.md



\## 12. Build order



| Phase | Work | Milestone |

|---|---|---|

| 0 | Data profiling, DECISIONS.md, PRD | Done when this PRD is complete |

| 1 | Star schema and dbt tests | |

| 2 | Analyses 1–5 on casino | |

| 3 | Fabric semantic model and DAX, report v1.0, two insight notes | Ready to apply |

| 4 | Sports brand, analysis 6, report v1.1 | |

| 5 | PoC 1 (early churn) | |

| 6 | Memo, spec, remaining notes, reviews, polish | |



\## 13. Success criteria



\- Every analysis has a written hypothesis and a clear confirmed/rejected result

\- At least one hypothesis is rejected and explained

\- All dbt tests pass

\- Every number in Power BI matches the SQL result it comes from

\- Each insight note fits on one page and ends with a recommendation

\- At least two real reviewers have given feedback



\## 14. Limitations



\- Payments only: no bets, stakes or gameplay.

\- No registration date: new players are defined as first seen from 1 May 2019.

\- "High-intensity" is defined from payment markers, not confirmed harm.

\- US data from 2019–2020, not Gaming1's markets: the project shows method, not current findings.

\- Teamwork cannot be shown by a solo project; it is covered by interview stories and real reviewers.

