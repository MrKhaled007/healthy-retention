\# Brief v2: restyle the Healthy Retention report to the approved design



\## Context

The report pages you generated (v1.0) work, but the design has changed.

The approved designs are in docs/design/\*.dc.html (HTML mockups, one per page).

Open them as a visual reference for layout, colours and chart types.

They are NOT code to copy into Power BI.



\## Hard rules (same as brief v1)

1\. Do NOT change anything in HealthyRetention.SemanticModel. No new measures, columns or tables.

&#x20;  If a visual needs a measure that does not exist, list it under "Measures needed".

&#x20;  Never hard-code a number into a visual or text box as if it came from the data.

2\. Use only existing measures and columns. Re-read the TMDL files first: I added and fixed some.

3\. Keep the hidden pages (verification, Player list, Tooltip) working. Restyle Player list and Tooltip to the new theme.

4\. Do not run git commit or git push.

5\. Produce valid PBIR. Update tools/gen\_report.py too, so it can regenerate the v2 report.

6\. Show me a plan first and wait for my approval.



\## Theme (replace the v1 theme)

\- Page background #1F2A33; header bar #17212A

\- Panels: background #26333E, border #36454F 1px, radius 4; panel title 14pt semibold with a thin divider line under it

\- Text: primary #E8EEF2, secondary #9DB0BE, muted #7D8F9C

\- KPI cards: title 13pt semibold, value 32pt regular, small grey subtitle

&#x20; - KPI value colours: green #4CC26A = working well, red #E5484D = problem, grey #C9D4DC = neutral

\- Watch group (high-intensity, 6+ declines): yellow #E5E067. Everyone else: blue #4C8DF6

\- Other categories, in this order: #4C8DF6, #7EB6FF, #8A6CF0, #9BD15A, #E5E067, #6ED6E8, #E39A86

\- Font Segoe UI. Page size 1280 x 720



\## Layout (all 5 main pages)

\- Top header bar (64 px): report title "Healthy Retention" on the left, page navigator as tabs in the

&#x20; middle (current page highlighted with a blue underline), dropdown slicers on the right.

&#x20; This replaces the v1 left navigation panel.

\- Top section: main chart panel on the left, a 3 x 2 grid of KPI cards on the right

\- Bottom section: three panels in a row (or the layout shown in the page's design file)

\- Footer line: source citation on the left, "Casino brand · v1.0 · Pacific time · USD" on the right

\- Remove the v1 "Insight" boxes, except where the design file shows a text panel

&#x20; (Healthy retention: Recommendation; Payment friction: One decline, two meanings)



\## Pages (follow each design file; key visuals)

1\. Deposit journey (JourneyV2.dc.html): FUNNEL visual, 'Journey Steps'\[Step Name] + \[Journey Players],

&#x20;  one colour per step; keep the bookmark toggle if it fits the layout, otherwise drop it and tell me.

&#x20;  Bottom: new players by cohort (columns), \[Journey % of Previous Step] as a step line,

&#x20;  players lost per step (labelled horizontal bars).

2\. Retention (RetentionV2.dc.html): heatmap matrix in blue shades (gradient #222D36 → #4C8DF6);

&#x20;  \[Retention M1] by cohort with an average line; May 2019 retention curve if possible with existing measures.

3\. Segments (SegmentsV2.dc.html): field-parameter buttons + bar chart (High-intensity yellow);

&#x20;  segment profile table; 100% stacked bars of share of players vs share of money.

4\. Healthy retention (HealthyV2.dc.html): threshold slider in the header; line chart of

&#x20;  Group Retention M1–M3 by Spend Group (early high-intensity yellow, others blue). If a line chart

&#x20;  with months on the axis is not possible with existing measures, explain and propose an alternative.

&#x20;  Two 100% stacked bars: \[Group % of M3 Active] and \[Group % of M3 Money].

5\. Payment friction (PaymentFrictionV2 = FrictionV2.dc.html): decline groups as labelled horizontal bars

&#x20;  (6+ declines yellow); approved vs declined first attempt (columns); the two-meanings text panel.



\## KPI cards

Use the KPIs shown in each design file. For every KPI that needs a measure that does not exist

(for example "Highest cohort", "9 of 9 within ±10 pts", "3.2x gap", "2 of 39"),

do not hard-code the number: leave the card in place with its title, and list the measure

under "Measures needed" with a one-line definition. I will write them in DAX myself.



\## When you finish

1\. Files created or changed

2\. Measures needed (name + one-line definition), so I can write them

3\. Anything not built as designed, and why

4\. A CHANGELOG.md entry: "v1.1 – restyled to approved v2 design"

