# Route Table Association
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Group
resource "aws_security_group" "web" {
  name        = "web-sg"
  description = "Allow web traffic"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "web-sg"
    Environment = var.environment
  }
}

# Security Group Rule with explicit dependency
resource "aws_security_group_rule" "http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web.id
  
  # Explicitly depend on the route table association to ensure
  # network routing is set up before allowing traffic
  depends_on = [aws_route_table_association.public]
}

# S3 Bucket Policy
resource "aws_s3_bucket_policy" "logs_policy" {
  bucket = aws_s3_bucket.logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject"
        ]
        Effect = "Allow"
        Resource = [
          aws_s3_bucket.logs.arn,
          "${aws_s3_bucket.logs.arn}/*"
        ]
        Principal = {
          AWS = data.aws_caller_identity.current.arn
        }
      }
    ]
  })
}

# S3 Bucket Versioning with explicit dependency
resource "aws_s3_bucket_versioning" "logs_versioning" {
  bucket = aws_s3_bucket.logs.id
  
  versioning_configuration {
    status = "Enabled"
  }
  
  # Explicitly depend on the bucket policy
  # This ensures the policy is fully applied before enabling versioning
  depends_on = [aws_s3_bucket_policy.logs_policy]
}

# S3 Bucket Logging configuration
resource "aws_s3_bucket_logging" "logs_logging" {
  bucket = aws_s3_bucket.logs.id

  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "log/"
  
  # Explicitly depend on bucket versioning
  # This creates a chain of dependencies: policy -> versioning -> logging
  depends_on = [aws_s3_bucket_versioning.logs_versioning]
}