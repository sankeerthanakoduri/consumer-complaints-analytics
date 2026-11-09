# Requirements Note

**Project:** Consumer Banking Complaints Analytics Platform
**Stakeholder persona:** Head of Customer Operations (a realistic persona for this portfolio project)

## Business problem
Operations leaders cannot see complaint volume, response timeliness and recurring issues in one place. Problems are found late, through escalations.

## Questions the dashboard must answer
1. How many complaints arrive each month, by product and by company?
2. What share of complaints get a timely response, and how many days does it take to reach the company?
3. Which issues and states are growing fastest?

## Users
- Operations heads: weekly review
- Team leads: daily filtering by product and company

## Refresh
Rebuilt from a new data download. Frequency: weekly (manual rerun for now).

## Data rules
- complaint_id must be unique.
- date_received must be a valid date and not in the future.
- date_sent_to_company must not be earlier than date_received.
- Blank product, issue or company values are flagged, not silently dropped.

## Out of scope (version 1)
Predictive modelling and complaint-text analysis.

## Success criteria
- One rerun rebuilds every table.
- Every data-quality check is logged with its result.
- The dashboard answers the three questions above.
