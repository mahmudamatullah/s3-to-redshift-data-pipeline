## Table of Contents

- [Project Overview](#overview)
- [Infrastructure / Architecture](#infrastructure--architecture)
- [Data Flow](#data-flow)
- [Tech Stack](#tech-stack)
- [How to Run](#how-to-run)
- [Key Features](#key-features)
- [Future Improvements](#future-improvements)
- [What I Learned](#what-i-learned)
- [Next Projects](#next-projects)

# Project Overview
* This project is an implementation of an end-to-end AWS-based data pipeline. The data (financial transactions) was generated using Python(Faker library), stored in S3, and then loaded into Amazon Redshift Serverless.
* All cloud infrastructure is provisioned using Terraform, and workflow orchestration is handled using Apache Airflow running locally in Docker.
* The project demonstrates infrastructure automation, secure service-to-service communication, and orchestrated data loading into a cloud data warehouse.
  
# Infrastructure / Architecture
* All AWS resources are provisioned using Terraform (Infrastructure as Code), this includes but not limited to:
* Custom VPC
* Subnets
* Security groups
* S3 bucket for data storage
* Amazon Redshift Serverless instance
* IAM roles and policies allowing Redshift to access S3
* Airflow is containerized using Docker and runs locally to orchestrate the pipeline.

# Data Flow
- Processed data is uploaded to the S3 bucket.
- Airflow reads the data from the s3 bucket and pushes it into Redshift as long as all conditions are satified.
- Redshift Serverless reads data from S3 using the assigned IAM role.
- Data is loaded into Redshift tables.
- Data becomes is now available for analytical queries.

🛠 Tech Stack
Terraform (infrastructure as code)
AWS S3

Amazon Redshift Serverless

IAM (AWS Identity and Access Management)

SQL
