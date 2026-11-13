\# Brief: generate the Healthy Retention Power BI report pages



\## Context

Portfolio project: player-journey analysis on real casino payment data (Ghaharian et al., 2023).

The semantic model is finished and verified by hand. Your job is the report layer only.



Project: powerbi/HealthyRetention.pbip

\- Semantic model (TMDL): powerbi/HealthyRetention.SemanticModel/  → READ ONLY

\- Report (PBIR):          powerbi/HealthyRetention.Report/         → you write here



\## Hard rules

1\. Do NOT change anything in HealthyRetention.SemanticModel. No new measures, columns or tables.

&#x20;  If a visual needs a measure that does not exist, do not invent it: list it under

&#x20;  "Measures needed" in your final summary, with a one-line description. I will write it by hand.

2\. Use only measures and columns that exist in the model. Read the TMDL files first.

3\. Do not delete or edit my existing verification pages. Set them to hidden.

4\. Do not run git commit or git push. I review and commit myself.

5\. Produce valid PBIR that opens in Power BI Desktop. Follow the existing files' structure and schemas.

6\. Before writing any file, show me a plan (pages, visuals, fields per visual, filters) and wait for my approval.



\## Look and feel (custom report theme)

Create a report theme and apply it to the report.

\- Page background #1C1C22; navigation panel #18181D; visual cards #25252D, border #34343E, radius 10

\- Text: primary #F4F2EC, secondary #A8A6B0

\- Accent gold #F2C66D = the group to watch (high-intensity, biggest drop, 6+ declines)

\- Blue #7FA7D9 = everyone else

\- Font: Segoe UI. Page titles 24pt semibold; KPI values 28pt

\- Page size 1280 × 720

\- Same frame on every page: left navigation panel with page buttons (current page highlighted gold),

&#x20; title as a question, dynamic subtitle (Title … measure), a row of 4 KPI cards, main chart(s),

&#x20; an "Insight" text box with a gold border, footer with source:

&#x20; "Source: Ghaharian et al. (2023), Mendeley Data, CC BY 4.0"



\## Pages



\### 1. Deposit journey

\- Page filters: dim\_player\[brand] = casino; dim\_player\[player\_type] = new;

&#x20; dim\_player\[cohort\_month] = May 2019 … Dec 2019

\- Subtitle: \[Title Journey]

\- Main visual: bar chart, axis 'Journey Steps'\[Step Name] (sorted by Step), value \[Journey Players]

\- Two bookmarks + toggle buttons: "% of new players" (\[Journey % of New Players])

&#x20; and "% of previous step" (\[Journey % of Previous Step])

\- KPIs: new players, reached first deposit %, never made a 2nd deposit (players lost), active in month 2 %

\- Insight: "The path to the first deposit works: 96% get there. After it, about half the players

&#x20; are lost at every step."



\### 2. Retention

\- Page filters: casino; new; cohort\_month = May 2019 … Jan 2020

\- Subtitle: \[Title Retention]

\- Main visual: matrix heatmap. Rows dim\_player\[cohort\_month] (format "mmm yyyy"),

&#x20; columns fct\_player\_month\[months\_since\_first\_seen] filtered 1–9, value \[Retention %].

&#x20; Background conditional formatting: gradient from #2A2720 (low) to #F2C66D (high).

\- Second visual: \[Retention M1] by cohort\_month with an average line

\- Slicers: cohort month, deposit segment

\- Insight: "Every cohort sits within 10 points of the average: retention is a stable pattern,

&#x20; not a seasonal effect."



\### 3. Segments

\- Page filters: casino; dim\_player\[deposit\_segment] excludes "No deposit"

\- Subtitle: \[Title Segments]

\- Field parameter 'Segment Measure' as button slicer (Share of players / Share of money / Median $/month)

\- Main visual: bar chart, axis dim\_player\[deposit\_segment], value = 'Segment Measure';

&#x20; title = \[Segment Chart Title]; High-intensity bar gold, others blue

\- Table: deposit\_segment with \[Players], \[% of Players], \[Deposit Amount], \[% of Deposit Money],

&#x20; \[Median Monthly Deposit]

\- Drill-through from deposit\_segment to the Player list page

\- Insight: "6% of depositors bring two-thirds of the money."



\### 4. Healthy retention

\- Page filters: casino; new; cohort\_month = May 2019 … Nov 2019

\- Subtitle: \[Title Healthy Retention]

\- Slider slicer on 'HI Threshold'\[HI Threshold] (single value, $500–$2,000), labelled

&#x20; "High-intensity threshold (what-if)"

\- Main visual: \[Group Retention M1], \[Group Retention M2], \[Group Retention M3] by 'Spend Group'\[Group]

&#x20; (early high-intensity gold, other depositors blue)

\- Visuals for \[Group % of M3 Active] and \[Group % of M3 Money] by 'Spend Group'\[Group]

\- KPI cards from the Group measures

\- Recommendation box: "Report retention separately for early high-intensity players, so targets

&#x20; never reward risky play."

\- Footer note: "High-intensity is a spending proxy, not confirmed harm."



\### 5. Payment friction

\- Page filters: casino; new; cohort\_month = May 2019 … Jan 2020;

&#x20; dim\_player\[first\_funding\_attempt\_status] not blank

\- Subtitle: \[Title Friction]

\- Visual: \[Retention M1] by dim\_player\[first\_funding\_attempt\_status]

\- Visual: \[Retention M1] and \[Players] by dim\_player\[Decline Group] (sorted by Decline Group Order,

&#x20; exclude "No funding attempt"); "6+ declines" bar gold

\- Drill-through from Decline Group to the Player list page

\- Text panel "One decline, two meanings":

&#x20; first attempt declined = a blocked new player → guide them on the spot;

&#x20; 6+ declines in 30 days = a player pushing past refusals → Duty of Care review



\### 6. Player list (drill-through page, hidden from navigation)

\- Drill-through fields: dim\_player\[deposit\_segment], dim\_player\[Decline Group]

\- Table: player\_id, cohort\_month, deposit\_segment, monthly\_deposit\_usd, first\_30d\_deposit\_usd,

&#x20; funding\_declines\_first\_30d, active\_m1, active\_m2, active\_m3

\- Back button



\### 7. Tooltip page (hidden)

\- Report-page tooltip for the Deposit journey bars: \[Journey Players] by dim\_player\[cohort\_month]



\## Interactions

\- Cross-filtering on between visuals on each page

\- All slicers sync only within their page



\## When you finish

Give me:

1\. A list of every file you created or changed

2\. "Measures needed", if any

3\. Anything you could not build as specified, and why

4\. A suggested CHANGELOG.md entry for "v1.0 – report pages generated with Claude Code"

