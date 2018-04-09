output "endpoint" {
  value = "${var.cluster ? aws_rds_cluster.this.endpoint : aws_db_instance.this.endpoint }"
}
