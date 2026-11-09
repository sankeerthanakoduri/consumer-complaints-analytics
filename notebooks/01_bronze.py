%python
import re
from pyspark.sql import functions as F

path = '/Volumes/workspace/complaints/raw/complaints_part*.csv'

df = (spark.read
      .option('header', True)
      .option('multiLine', True)
      .option('escape', '"')
      .csv(path))

def clean(c):
    return re.sub(r'[^0-9a-zA-Z]+', '_', c.strip()).strip('_').lower()

df = df.toDF(*[clean(c) for c in df.columns])

df = (df.select('*', F.col('_metadata.file_name').alias('_source_file'))
        .withColumn('_ingested_at', F.current_timestamp()))

print(df.columns)

df.write.mode('overwrite').saveAsTable('workspace.complaints.bronze_complaints')
print('bronze table written')

%sql
SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT complaint_id) AS distinct_ids
FROM workspace.complaints.bronze_complaints

%sql
SELECT _source_file, COUNT(*) AS rows_in_file
FROM workspace.complaints.bronze_complaints
GROUP BY _source_file
