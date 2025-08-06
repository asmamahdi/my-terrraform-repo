# RDS MySQL Instance
resource "aws_db_instance" "practice_db" {
  parameter_group_name = aws_db_parameter_group.updated_db_parameter_group.name

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
  backup_window           = "03:00-04:00"  # UTC
  maintenance_window      = "sun:04:00-sun:05:00"  # UTC

  # Monitoring
  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_enhanced_monitoring.arn

  # Performance Insights
  performance_insights_enabled = false
  # (Do not include retention period if insights are disabled)

  # Logging
  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]

  # Deletion Protection
  deletion_protection = false
  skip_final_snapshot = true

  tags = {
    Name = "${var.environment}-rds-mysql"
  }

  depends_on = [
    aws_cloudwatch_log_group.rds_logs
  ]
}
