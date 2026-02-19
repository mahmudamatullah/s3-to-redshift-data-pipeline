# S3 to Redshift Batch Data Pipeline
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=flat&logo=amazon-aws&logoColor=white)
![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=flat&logo=terraform&logoColor=white)

## Table of Contents

- [Overview](#overview)
- [Infrastructure / Architecture](#infrastructure--architecture)
- [Data Generation](#data-generation)
- [Data Pipeline Flow](#data-pipeline-flow)
- [Tech Stack](#tech-stack)
- [How to Run](#how-to-run)
- [Key Features](#key-features)
- [Future Improvements](#future-improvements)
- [What I Learned](#what-i-learned)
- [Next Projects](#next-projects)

---

## Overview

→ This project is an implementation of a repeatable, end-to-end AWS batch data pipeline that simulates recurring large-scale ingestion into a cloud data warehouse.

→ The source data (financial transactions) was dynamically generated using Python (Faker library), stored in Amazon S3 in Parquet format, and loaded into Amazon Redshift Serverless for analytics via two orchestrated Airflow DAGs.

→ All infrastructure is provisioned using Terraform, and workflow orchestration is handled by Apache Airflow running locally in Docker.

--- 

## Infrastructure / Architecture
All AWS resources were provisioned using Terraform (Infrastructure as Code), which includes but not limited to:
- Custom VPC  
- Subnets  
- Security groups  
- S3 bucket for data storage  
- Amazon Redshift Serverless instance  
- IAM roles and policies for secure S3 → Redshift access
- Airflow is containerized using Docker and runs locally to orchestrate the pipeline.

## Data Generation
Transaction data was generated using Python and the Faker library.
_Key characteristics:_
 - Each pipeline run generates 500,000 to 1,000,000 records that varies per execution.
 - Files are timestamped using the current execution date.
> The reason was to simulate controlled and repeatable testing without relying on external datasets.

## Data Pipeline Flow
1. Terraform provisions AWS infrastructure.  
2. **DAG 1 – Data Generation → S3:**  
   - Generates 500k–1M synthetic transaction records using Python and Faker  
   - Writes Parquet files to S3 with date-stamped filenames  
3. **DAG 2 – S3 → Redshift Load:**  
   - Loads the Parquet files into Redshift
   - Appends new records to the existing warehouse records  
4. Data is now available for analytics  

## Tech Stack
- Python (Faker)
- AWS Wrangler
- Terraform
- AWS S3, IAM
- Amazon Redshift Serverless
- Apache Airflow
- Docker


## How to Run

### 1. Prerequisites
Before running the pipeline, you need to have:

- An AWS account with access
- Terraform installed locally
- Docker installed
- Apache Airflow installed via Docker, or the script can be copied if it's on the cloud.
- Optional: Python (for local scripts/tests)

---

### 2. Provision AWS Infrastructure
``bash
terraform init
terraform apply``

> Terraform will create the necessary resources mentioned in the Architecture/ Infrastructure
> Note: Replace any placeholder variables in Terraform with your own AWS credentials and preferred naming.

### 3. Start Airflow (Docker)
`docker-compose up` - This will launch the Airflow webserver and scheduler locally.

Access the Airflow UI at:
`http://localhost:8080`

4. Configure Airflow Connections

The DAG references two connections:

| Connection ID   | Type                  | Description                                                      |
|-----------------|----------------------|------------------------------------------------------------------|
| amatullah       | Amazon Web Services   | Link to your AWS account (provide Access Key & Secret)           |
| my_redshift     | Amazon Redshift       | Link to your Redshift Serverless instance (host, database, user, password, port) |

Tip: Use Airflow UI → Admin → Connections to add these.
You can use placeholder values to test or your own credentials.

5. Trigger the DAG
- Locate the DAG moving_data_to_s3 in the Airflow UI.
- Turn it on and click Trigger DAG.
- DAG 1 will generate the transaction data and upload it to S3.
- DAG 2 will load the data into Redshift (append-only).
- Each run generates 500k–1M records and stores them in date-stamped Parquet files.

7. Notes
This project is intended to be run with your own AWS account.
The pipeline is modular, which means the DAGs can be executed independently for testing or full ingestion.


## Key Features
- Fully automated infrastructure using Terraform
- Custom AWS networking configuration
- Secure IAM role-based service communication
- Dynamic large-batch data generation (500k–1M records per run)
- Parquet-based storage for optimized warehouse loading
- Append-only loading
- Containerized Airflow orchestration

## Future Improvements
- CI/CD for infrastructure deployment
- Deploying Airfow in an Ec2

## What I Learnt
- Designing secure AWS networking and IAM configurations
- Understanding Infrastructure
- Building modular, and dynamic batch ingestion pipelines
- Orchestrating multiple workflows with Airflow
- Generating synthetic datasets with Faker
