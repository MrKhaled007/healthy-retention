# Changelog

## v1.1 – restyled to approved v2 design

Report only. The semantic model is unchanged. Regenerate with
`python ../tools/gen_report.py HealthyRetention.Report` from `powerbi/`.

### Changed
- New theme (`HealthyRetention.json`): page #1F2A33, header #17212A, panels #26333E with a 1px #36454F
  border and radius 4, text #E8EEF2 / #9DB0BE / #7D8F9C, Segoe UI. Watch group (high-intensity, 6+ declines)
  is yellow #E5E067, everyone else blue #4C8DF6.
- Layout on all 5 main pages: 64 px header bar (title, page tabs with a blue underline on the current page,
  dropdown slicers on the right), main chart panel + 3 x 2 KPI grid on top, three bottom panels, footer line.
  Replaces the v1 left navigation panel.
- KPI cards: 13pt title with divider, 32pt value coloured green / red / grey, grey subtitle.
- Deposit journey: funnel per step; new players by cohort; step conversion as a stepped line.
- Retention: blue heatmap; month-1 retention by cohort with average line; May 2019 retention curve.
- Segments: measure buttons + bar chart; segment profile table; players vs money 100% stacked bars.
- Healthy retention: threshold slider in the header; retention M1–M3 by spend group (clustered columns);
  two 100% stacked bars for share of month-3 active players and money; Recommendation panel.
- Payment friction: month-1 retention by decline group; approved vs declined first attempt;
  "One decline, two meanings" panel.
- Player list and tooltip pages restyled to the new theme; drill-through and tooltip bindings unchanged.

### Removed
- v1 "Insight" boxes (except the two text panels kept by the design).
- Deposit journey bookmark toggle (% of new players / % of previous step) and its two bookmarks:
  the funnel shows % of the first step and the new step-conversion chart shows % of the previous step.
- Player type slicer on Deposit journey (the page is filtered to new players).

### Pending (waiting for measures)
- KPI cards and panels marked "Needs measure" keep their place and title until the measures exist:
  Journey Players Lost, Highest / Lowest Cohort M1, Cohorts Within 10 Pts, Long-term Core Range,
  Retention M1 vs Average, HI % of Deposit Money, Avg Funding Declines per Player,
  Avg Deposit Days per Month, Group Retention Gap M3, Declined First Then Deposited, First Attempt M1 Gap.
