output "endpoint" {
  #value = "${aws_db_instance.this.0.endpoint}"
  value = ["${compact(concat(aws_rds_cluster_instance.this.*.endpoint, aws_db_instance.this.*.endpoint))}"]
}
output "address" {
  #value = "${aws_db_instance.this.0.address}"
  value = "${element(compact(concat(list(var.cluster), aws_db_instance.this.*.address)), 0)}"
}
