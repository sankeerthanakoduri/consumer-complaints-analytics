# Data Profile

**Source:** CFPB Consumer Complaint Database (consumerfinance.gov/data-research/consumer-complaints), downloaded 9 Nov 2026.

**Filters:** date received 2025-11-09 to 2026-11-08; products: Checking or savings account, Prepaid card, Mortgage.

**Export:** the site limits filtered exports to 100,000 complaints, so the data was exported in two CSV files:
- Part 1: 63,987 rows (9 Nov 2025 to 8 May 2026), 17.5 MB
- Part 2: 64,806 rows (9 May 2026 to 8 Nov 2026), 17.4 MB

**Total rows:** 128,793. **Duplicate complaint IDs:** 0.
**Actual date received range:** 2025-11-09 to 2026-11-06 (UTC timestamps).

## Columns (15)
Date received, Product, Sub-product, Issue, Sub-issue, Company public response, Company, State, ZIP code, Tags, Submitted via, Date sent to company, Company response to consumer, Timely response?, Complaint ID

## Product mix
- Checking or savings account: 88,816
- Mortgage: 33,714
- Prepaid card: 6,263

## Timely response
- Yes: 126,468
- No: 2,325

## Blank values
- Sub-issue: 810
- Company public response: 77,528 (expected, only filled when the company chooses a public response)
- State: 1,289
- ZIP code: 694
- Tags: 104,097 (expected, tags apply only to some complaints)
- All other columns: 0
