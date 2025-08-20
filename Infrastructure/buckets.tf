resource "aws_s3_bucket" "s3_bucket_instance" {
  bucket = "capstone-project-data-11"

  tags = {
    name= "capstone project"
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.s3_bucket_instance.id

  versioning_configuration {
    status = "Enabled"
  }
}
