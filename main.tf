locals {
  id = "${replace(var.name, " ", "-")}"
}

# -----------------------------------------------
# Create Private subnets
# -----------------------------------------------
resource "aws_subnet" "this" {
  count = "${length(var.azs)}"
  vpc_id = "${data.aws_vpc.this.id}"
  cidr_block = "${cidrsubnet(data.aws_vpc.this.cidr_block, var.newbits, var.netnum + count.index)}"
	availability_zone = "${element(var.azs, count.index)}"
	map_public_ip_on_launch = false
  tags = "${merge(var.tags, map("Name", "${var.name} DB ${count.index}"))}"
}

resource "aws_route_table_association" "this" {
  count = "${length(var.azs)}"
  subnet_id = "${element(aws_subnet.this.*.id, count.index)}"
  route_table_id = "${var.rt_id}"
}

# ------------------------------------------------------------------------------------------
# CREATE DB SUBNET GROUP
# -------------------------------------------------------------------------------------------
resource "aws_db_subnet_group" "this" {
  name       = "${lower(local.id)}"
  subnet_ids = ["${aws_subnet.this.*.id}"]
  description = "${var.name} DB subnet group"
  tags = "${merge(var.tags, map("Name", "${var.name}"))}"
}

# -------------------------------
# CREATE AURORA CLUSTER
# -------------------------------
resource "aws_rds_cluster_instance" "this" {
  identifier         = "${lower(local.id)}"
  cluster_identifier = "${aws_rds_cluster.this.id}"
  instance_class     = "${var.type}"
  db_subnet_group_name = "${aws_db_subnet_group.this.name}"
  engine = "${var.engine}"
}

resource "aws_rds_cluster" "this" {
  cluster_identifier = "${lower(local.id)}"
  availability_zones = ["${var.azs}"]
  database_name      = "${var.db_name}"
  master_username    = "${var.db_user}"
  master_password    = "${var.db_password}"
  db_subnet_group_name = "${aws_db_subnet_group.this.name}"
  vpc_security_group_ids = ["${aws_security_group.this.id}"]
  final_snapshot_identifier = "${local.id}"
}

# ---------------------------------------
# Network ACL DB
# ---------------------------------------
resource "aws_network_acl" "this" {
  vpc_id = "${data.aws_vpc.this.id}"
  subnet_ids = ["${aws_subnet.this.*.id}"]
  tags = "${merge(var.tags, map("Name", "${var.name} DB"))}"
}

# ---------------------------------------
# Network ACL Inbound/Outbound DB
# ---------------------------------------
resource "aws_network_acl_rule" "inbound" {
  count = "${length(var.azs)}"
  network_acl_id = "${aws_network_acl.this.id}"
  rule_number    = "${(count.index+1)*100}"
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "${element(var.access_cidrs, count.index)}"
  from_port      = 3306
  to_port        = 3306
}

resource "aws_network_acl_rule" "outbound" {
  count = "${length(var.azs)}"
  network_acl_id = "${aws_network_acl.this.id}"
  rule_number    = "${(count.index+1)*100}"
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "${element(var.access_cidrs, count.index)}"
  from_port      = 1024
  to_port        = 65535
}

# Security group Database access
resource "aws_security_group" "this" {
  name = "${local.id}-DB"
  description = "Access to DB port (3306)"
  vpc_id = "${data.aws_vpc.this.id}"

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = ["${var.access_sg_ids}"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(var.tags, map("Name", "${var.name} DB"))}"
}

resource "aws_route53_record" "this" {
  zone_id = "${var.zone_id}"
  name = "${var.record}"
  type = "CNAME"
  ttl = "600"
  records = ["${aws_rds_cluster.this.endpoint}"]
}
