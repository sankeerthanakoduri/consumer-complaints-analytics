CREATE OR REPLACE TABLE workspace.complaints.silver_complaints AS
WITH parsed AS (
  SELECT
    CASE WHEN UPPER(TRIM(complaint_id)) IN ('', 'NONE', 'N/A', 'NA', 'NULL', 'NAN') THEN NULL ELSE TRIM(complaint_id) END AS complaint_id,
    try_to_date(substr(date_received, 1, 10), 'yyyy-MM-dd') AS date_received,
    try_to_date(substr(date_sent_to_company, 1, 10), 'yyyy-MM-dd') AS date_sent_to_company,
    CASE WHEN UPPER(TRIM(product)) IN ('', 'NONE', 'N/A', 'NA', 'NULL', 'NAN') THEN NULL ELSE TRIM(product) END AS product,
    CASE WHEN UPPER(TRIM(sub_product)) IN ('', 'NONE', 'N/A', 'NA', 'NULL', 'NAN') THEN NULL ELSE TRIM(sub_product) END AS sub_product,
    CASE WHEN UPPER(TRIM(issue)) IN ('', 'NONE', 'N/A', 'NA', 'NULL', 'NAN') THEN NULL ELSE TRIM(issue) END AS issue,
    CASE WHEN UPPER(TRIM(sub_issue)) IN ('', 'NONE', 'N/A', 'NA', 'NULL', 'NAN') THEN NULL ELSE TRIM(sub_issue) END AS sub_issue,
    CASE WHEN UPPER(TRIM(company)) IN ('', 'NONE', 'N/A', 'NA', 'NULL', 'NAN') THEN NULL ELSE TRIM(company) END AS company,
    CASE WHEN UPPER(TRIM(state)) IN ('', 'NONE', 'N/A', 'NA', 'NULL', 'NAN') THEN NULL ELSE UPPER(TRIM(state)) END AS state,
    CASE WHEN UPPER(TRIM(zip_code)) IN ('', 'NONE', 'N/A', 'NA', 'NULL', 'NAN') THEN NULL ELSE TRIM(zip_code) END AS zip_code,
    CASE WHEN UPPER(TRIM(submitted_via)) IN ('', 'NONE', 'N/A', 'NA', 'NULL', 'NAN') THEN NULL ELSE TRIM(submitted_via) END AS submitted_via,
    CASE WHEN UPPER(TRIM(company_public_response)) IN ('', 'NONE', 'N/A', 'NA', 'NULL', 'NAN') THEN NULL ELSE TRIM(company_public_response) END AS company_public_response,
    CASE WHEN UPPER(TRIM(company_response_to_consumer)) IN ('', 'NONE', 'N/A', 'NA', 'NULL', 'NAN') THEN NULL ELSE TRIM(company_response_to_consumer) END AS company_response_to_consumer,
    CASE WHEN UPPER(TRIM(timely_response)) IN ('', 'NONE', 'N/A', 'NA', 'NULL', 'NAN') THEN NULL ELSE TRIM(timely_response) END AS timely_response,
    CASE WHEN UPPER(TRIM(tags)) IN ('', 'NONE', 'N/A', 'NA', 'NULL', 'NAN') THEN NULL ELSE TRIM(tags) END AS tags,
    _source_file
  FROM workspace.complaints.bronze_complaints
),
ranked AS (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY complaint_id ORDER BY _source_file DESC) AS rn
  FROM parsed
  WHERE complaint_id IS NOT NULL
)
SELECT
  complaint_id, date_received, date_sent_to_company,
  date_format(date_received, 'yyyy-MM') AS year_month,
  datediff(date_sent_to_company, date_received) AS days_to_company,
  product, sub_product, issue, sub_issue, company, state, zip_code, submitted_via,
  company_public_response, company_response_to_consumer, timely_response,
  CASE WHEN timely_response = 'Yes' THEN TRUE
       WHEN timely_response = 'No' THEN FALSE END AS timely_flag,
  tags, _source_file
FROM ranked
WHERE rn = 1;
