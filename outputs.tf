output "endpoint" {
  #value = "${aws_rds_cluster_instance.this.0.endpoint}"
  #value = "${var.cluster ? aws_rds_cluster_instance.this.0.endpoint : aws_db_instance.this.0.endpoint }"
  #value = "${element(compact(concat(list(var.cluster), aws_rds_cluster_instance.this.*.endpoint)), 0)}"
  value = ["${compact(concat(aws_rds_cluster_instance.this.*.endpoint, aws_db_instance.this.*.endpoint))}"]
}
output "address" {
  #value = "${aws_db_instance.this.0.address}"
  value = "${element(compact(concat(list(var.cluster), aws_db_instance.this.*.address)), 0)}"
}

output "cluster_endpoint" {
  value = "${element(compact(concat(list(var.cluster), aws_rds_cluster.this.*.endpoint)), 0)}"
}