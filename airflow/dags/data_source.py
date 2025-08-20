import random
from datetime import datetime

import awswrangler as wr
import boto3
import pandas as pd
from airflow.models import Variable
from faker import Faker

faker = Faker()


def transaction_dataset(num_records):
    source_data = []
    for i in range(num_records):
        transaction_data = {
            "transaction_id": faker.uuid4(),
            "user_id": int(random.randint(1000, 9999)),
            "amount": round(random.uniform(5.0, 1000.0), 2),
            "currency": random.choice(["USD", "EUR", "GBP", "NGN"]),
            "timestamp": faker.date_time_this_year(),
            "merchant": faker.company(),
            "location": faker.city(),
            "payment_method": random.choice(
                ["credit_card", "debit_card", "paypal", "bank_transfer"]
            ),
            "status": random.choice(["success", "failed", "pending"]),
        }
        source_data.append(transaction_data)
    return pd.DataFrame(source_data)


def upload_to_s3():
    num_records = random.randint(500_000, 1_000_000)
    df_data = transaction_dataset(num_records)
    session = boto3.Session(
        aws_access_key_id=Variable.get("ACCESS_KEY"),
        aws_secret_access_key=Variable.get("SECRET_KEY"),
        region_name="eu-north-1",
    )
    current_date = datetime.now().strftime("%d-%m-%Y")
    wr.s3.to_parquet(
        df=df_data,
        path=(f"s3://capstone-project-data-11/{current_date}-"
              f"transactions_data.parquet"),
        boto3_session=session,
    )
