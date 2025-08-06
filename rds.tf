# RDS MySQL Database Configuration
# Owner: Touqeer Hussain

# DB Subnet Group
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.environment}-db-subnet-group"
  subnet_ids = aws_subnet.private_db_subnets[*].id

  tags = {
    Name = "${var.environment}-db-subnet-group"
  }
}

# DB Parameter Group
resource "aws_db_parameter_group" "db_parameter_group" {
  family = "mysql8.0"
  name   = "${var.environment}-db-parameter-group"

  parameter {
    name  = "innodb_buffer_pool_size"
    value = "{DBInstanceClassMemory*3/4}"
  }

parameter {
  name  = "character_set_server"
  value = "utf8"
}

parameter {
  name  = "collation_server"
  value = "utf8_general_ci"
}


  parameter {
    name  = "slow_query_log"
    value = "1"
  }

  parameter {
    name  = "general_log"
    value = "1"
  }

  tags = {
    Name = "${var.environment}-db-parameter-group"
  }
}

# RDS MySQL Instance
resource "aws_db_instance" "practice_db" {
  identifier = "${var.environment}-rds-mysql"

  # Engine Configuration
  engine         = var.db_engine
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class

  # Storage Configuration
  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = 100
  storage_type          = "gp2"
  storage_encrypted     = true

  # Database Configuration
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = 3306

  # Network Configuration
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible    = false

  # High Availability
  multi_az = true

  # Backup Configuration
  backup_retention_period = var.backup_retention_period
  backup_window          = "03:00-04:00"  # UTC
  maintenance_window     = "sun:04:00-sun:05:00"  # UTC

  # Parameter and Option Groups
  parameter_group_name = aws_db_parameter_group.db_parameter_group.name

  # Monitoring
  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_enhanced_monitoring.arn

  # Performance Insights
  performance_insights_enabled = true
  performance_insights_retention_period = 7

  # Logging
  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]

  # Deletion Protection
  deletion_protection = false  # Set to true for production
  skip_final_snapshot = true   # Set to false for production

  # Final snapshot identifier (uncomment for production)
  # final_snapshot_identifier = "${var.environment}-rds-mysql-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  tags = {
    Name = "${var.environment}-rds-mysql"
  }

  depends_on = [
    aws_cloudwatch_log_group.rds_logs
  ]
}

# IAM Role for RDS Enhanced Monitoring
resource "aws_iam_role" "rds_enhanced_monitoring" {
  name = "${var.environment}-rds-enhanced-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.environment}-rds-enhanced-monitoring-role"
  }
}

# Attach AWS managed policy for RDS Enhanced Monitoring
resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  role       = aws_iam_role.rds_enhanced_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# CloudWatch Log Groups for RDS
resource "aws_cloudwatch_log_group" "rds_logs" {
  for_each = toset(["error", "general", "slow_query"])
  
  name              = "/aws/rds/instance/${var.environment}-rds-mysql/${each.key}"
  retention_in_days = 7

  tags = {
    Name = "${var.environment}-rds-${each.key}-logs"
  }
}

# RDS Read Replica (optional - uncomment if needed)
/*
resource "aws_db_instance" "practice_db_replica" {
  identifier = "${var.environment}-rds-mysql-replica"
  
  replicate_source_db = aws_db_instance.practice_db.identifier
  instance_class      = var.db_instance_class
  
  publicly_accessible = false
  
  # Monitoring
  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_enhanced_monitoring.arn
  
  # Performance Insights
  performance_insights_enabled = true
  performance_insights_retention_period = 7
  
  tags = {
    Name = "${var.environment}-rds-mysql-replica"
  }
}
*/
