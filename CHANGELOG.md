# Changelog

## v1.1.1 – fixes after the first Desktop review

Report only. The semantic model is unchanged.

- Header tabs now use the built-in page navigator (the hand-made tab buttons showed no text).
  Pages renamed to their tab names: "Deposit journey" → "Journey", "Payment friction" → "Friction".
  The blue underline is dropped; the current page has a #2F4050 fill and white semibold text.
- Header and footer text boxes: padding 0 and enough height, which removes the overflow scrollbars
  (the stray white rectangles). Slicer labels widened; dropdown slicers 40 px tall.
- Footer split sized to its text. The generator now stops if a label, tab name or footer line would not fit,
  or if header controls would overlap the navigator.
- Chart labels show whole numbers (display units None), e.g. 1,069 instead of 1K.
- Retention heatmap: fixed column widths, one text colour #E8EEF2, gradient #2A3E58 → #2C5FBD
  (contrast 9.3:1 to 5.2:1). The generated average line is removed; add it in the Analytics pane.
- Segments: "Players vs money" bars use the share measures with 1-decimal labels and the segment colours;
  the measure-button bar chart uses #36454F label chips.
- Payment friction: decline-group labels sit inside the bars in dark #17212A text.
- Player list: Back button 40 px tall, semibold text.

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

### Fixed by hand in Desktop
- Healthy retention: threshold slicer replaced by a new numeric single-value slicer (input box, no slider).
  Its format is copied into `tools/gen_report.py`: the value is stored as a double in `numericStart`
  and in the slicer filter.
- Retention: average line added to "Month-1 retention by cohort" in the Analytics pane.
- Model: `deposit_segment` sorted by `deposit_segment_order` (new dbt column), so segments follow
  spend order (One-and-done, Light, Regular, High-intensity), including in the "Players vs money" bars.
