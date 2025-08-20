resource "aws_vpc" "capstone_project_vpc_instance" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "capstone-project"
  }
}

resource "aws_subnet" "subnet_a" {
  vpc_id     = aws_vpc.capstone_project_vpc_instance.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-north-1a"
}

resource "aws_subnet" "subnet_b" {
  vpc_id     = aws_vpc.capstone_project_vpc_instance.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "eu-north-1b"
}

resource "aws_internet_gateway" "access_public" {
  vpc_id = aws_vpc.capstone_project_vpc_instance.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.capstone_project_vpc_instance.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.access_public.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.subnet_b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "redshift_sg" {
  name   = "redshift-securitygroup"
  vpc_id = aws_vpc.capstone_project_vpc_instance.id

  ingress {
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "redshift_to_s3_role" {
  name = "capstone-redshift-to-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "redshift.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "policy_for_the_bucket" {
  name        = "capstone-redshift-to-s3-read-from-bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      Resource = [
        "arn:aws:s3:::capstone-project-data-11",
        "arn:aws:s3:::capstone-project-data-11/*"
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy_to_bucket" {
  role       = aws_iam_role.redshift_to_s3_role.name
  policy_arn = aws_iam_policy.policy_for_the_bucket.arn
}

resource "aws_redshift_subnet_group" "capstone_subnet_group" {
  name       = "capstone-redshift-subnet-group"
  subnet_ids = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]
}

resource "aws_redshiftserverless_namespace" "capstone_namespace" {
  namespace_name      = "capstone-namespace"
  db_name       = "my_database"
  admin_username     = var.redshift_username
  admin_user_password = var.redshift_password
  iam_roles = [aws_iam_role.redshift_to_s3_role.arn]
}


resource "aws_redshiftserverless_workgroup" "capstone_workgroup" {
  workgroup_name     = "capstone-workgroup"
  namespace_name     = aws_redshiftserverless_namespace.capstone_namespace.namespace_name
  subnet_ids         = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]
  security_group_ids = [aws_security_group.redshift_sg.id]
  publicly_accessible = true
  
}


