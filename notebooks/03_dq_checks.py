%python
import uuid
from datetime import datetime

run_id = str(uuid.uuid4())[:8]
run_ts = datetime.now()
silver = 'workspace.complaints.silver_complaints'
bronze = 'workspace.complaints.bronze_complaints'
rows = []
total = spark.table(silver).count()

def check(name, severity, bad_condition, reason):
    bad = spark.table(silver).filter(bad_condition).count()
    rows.append((run_id, run_ts, name, severity, total, bad, bad == 0, reason))

# Errors: these should never happen
check('complaint_id_not_null', 'error', 'complaint_id IS NULL', 'Every complaint needs an ID')
check('date_received_valid', 'error', 'date_received IS NULL', 'Date received must be a real date')
check('date_sent_valid', 'error', 'date_sent_to_company IS NULL', 'Date sent must be a real date')
check('date_received_not_future', 'error', 'date_received > current_date()', 'A complaint cannot be received in the future')
check('sent_not_before_received', 'error', 'date_sent_to_company < date_received', 'A complaint cannot be sent before it is received')
check('product_not_null', 'error', 'product IS NULL', 'Product is needed for every KPI')
check('company_not_null', 'error', 'company IS NULL', 'Company is needed for every KPI')
check('issue_not_null', 'error', 'issue IS NULL', 'Issue is needed for issue trends')
check('timely_response_valid', 'error', "timely_response IS NULL OR timely_response NOT IN ('Yes','No')", 'Timely response must be Yes or No')

# Warnings: worth knowing, not necessarily wrong
check('state_missing', 'warning', 'state IS NULL', 'Missing state weakens the state view')
check('state_not_two_letters', 'warning', 'state IS NOT NULL AND LENGTH(state) <> 2', 'US state codes have two letters')
check('zip_missing', 'warning', 'zip_code IS NULL', 'Missing ZIP code')
check('slow_to_reach_company', 'warning', 'days_to_company > 30', 'More than 30 days from receipt to sending to the company')

# Placeholder words must not survive into silver
ph = "('NONE','N/A','NA','NULL','NAN')"
check('placeholder_text_left', 'error',
      f"UPPER(state) IN {ph} OR UPPER(zip_code) IN {ph} OR UPPER(sub_issue) IN {ph} OR UPPER(company_public_response) IN {ph} OR UPPER(tags) IN {ph}",
      'Placeholder words like None must be converted to NULL in silver')
check('zip_fully_masked', 'warning', "zip_code = 'XXXXX'", 'ZIP fully masked by the CFPB for privacy')

# Uniqueness and reconciliation
distinct_ids = spark.table(silver).select('complaint_id').distinct().count()
dups = total - distinct_ids
rows.append((run_id, run_ts, 'complaint_id_unique', 'error', total, dups, dups == 0, 'One row per complaint'))

bronze_ids = spark.table(bronze).select('complaint_id').distinct().count()
gap = bronze_ids - total
rows.append((run_id, run_ts, 'bronze_silver_reconciliation', 'error', bronze_ids, gap, gap == 0, 'Every bronze complaint ID must reach silver'))

schema = ('run_id string, run_ts timestamp, check_name string, severity string, '
          'total_rows long, failed_rows long, passed boolean, reason string')
spark.createDataFrame(rows, schema).write.mode('append').saveAsTable('workspace.complaints.dq_results')

display(spark.table('workspace.complaints.dq_results').filter(f"run_id = '{run_id}'"))
