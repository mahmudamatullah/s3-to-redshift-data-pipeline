from datetime import datetime

from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.amazon.aws.transfers.s3_to_redshift import \
    S3ToRedshiftOperator

from data_source import upload_to_s3

S3_BUCKET = "capstone-project-data-11"
current_date = datetime.today().strftime("%d-%m-%Y")
S3_KEY = f"{current_date}-transactions_data.parquet"
S3_PATH = f"s3://capstone-project-data-11/{S3_KEY}"
REDSHIFT_SCHEMA = "capstone_data"
REDSHIFT_TABLE = "transactions"
REDSHIFT_CONN_ID = "my_redshift"
AWS_CONN_ID = "amatullah"

default_args = {
    "owner": "airflow",
    "start_date": datetime(2025, 8, 14),
    "retries": 1,
}

with DAG(
    dag_id="moving_data_to_s3",
    default_args=default_args,
    schedule_interval="@daily",
    description="Upload the data to S3 and from there into Redshift(serverless)",
) as dag:

    upload_task = PythonOperator(
        task_id="upload_generated_data_to_s3",
        python_callable=upload_to_s3
    )

    load_into_redshift_task = S3ToRedshiftOperator(
        task_id="load_data_from_s3_to_redshift_serverless",
        schema=REDSHIFT_SCHEMA,
        table=REDSHIFT_TABLE,
        s3_bucket=S3_BUCKET,
        s3_key=S3_KEY,
        copy_options=["FORMAT AS PARQUET", "REGION 'eu-north-1'"],
        redshift_conn_id=REDSHIFT_CONN_ID,
        aws_conn_id=AWS_CONN_ID
    )

    upload_task >> load_into_redshift_task
