CREATE OR REPLACE TABLE workspace.complaints.silver_complaints AS
WITH parsed AS (
  SELECT
    NULLIF(TRIM(complaint_id), '') AS complaint_id,
    try_to_date(substr(date_received, 1, 10), 'yyyy-MM-dd') AS date_received,
    try_to_date(substr(date_sent_to_company, 1, 10), 'yyyy-MM-dd') AS date_sent_to_company,
    NULLIF(TRIM(product), '') AS product,
    NULLIF(TRIM(sub_product), '') AS sub_product,
    NULLIF(TRIM(issue), '') AS issue,
    NULLIF(TRIM(sub_issue), '') AS sub_issue,
    NULLIF(TRIM(company), '') AS company,
    UPPER(NULLIF(TRIM(state), '')) AS state,
    NULLIF(TRIM(zip_code), '') AS zip_code,
    NULLIF(TRIM(submitted_via), '') AS submitted_via,
    NULLIF(TRIM(company_public_response), '') AS company_public_response,
    NULLIF(TRIM(company_response_to_consumer), '') AS company_response_to_consumer,
    NULLIF(TRIM(timely_response), '') AS timely_response,
    NULLIF(TRIM(tags), '') AS tags,
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
