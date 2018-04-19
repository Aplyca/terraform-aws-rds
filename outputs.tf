output "endpoint" {
  value = "${aws_db_instance.this.0.endpoint}"
}
output "address" {
  value = "${aws_db_instance.this.0.address}"
}
