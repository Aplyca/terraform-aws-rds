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
# CREATE RDS
# -------------------------------

resource "aws_db_instance" "this" {
  count = "${var.cluster ? 0 : 1 }"
  identifier           = "${lower(local.id)}"
  allocated_storage    = "${var.storage}"
  storage_type         = "gp2"
  engine               = "${var.engine}"
  engine_version       = "${var.engine_version}"
  instance_class       = "${var.type}"
  name                 = "${var.db_name}"
  username             = "${var.db_user}"
  password             = "${var.db_password}"
  snapshot_identifier  = "${var.db_snapshot_identifier}"
  db_subnet_group_name = "${aws_db_subnet_group.this.name}"
  vpc_security_group_ids = ["${aws_security_group.this.id}"]
  final_snapshot_identifier = "${local.id}"
  tags = "${merge(var.tags, map("Name", var.name))}"
  copy_tags_to_snapshot = true
  backup_retention_period = 7
  storage_encrypted = true
}

resource "aws_rds_cluster_instance" "this" {
  count = "${var.cluster ? 1 : 0 }"
  engine = "${var.engine}"
  identifier         = "${lower(local.id)}"
  cluster_identifier = "${aws_rds_cluster.this.id}"
  instance_class     = "${var.type}"
  db_subnet_group_name = "${aws_db_subnet_group.this.name}"
}

resource "aws_rds_cluster" "this" {
  count = "${var.cluster ? 1 : 0 }"
  engine = "${var.engine}"
  cluster_identifier = "${lower(local.id)}"
  availability_zones = ["${var.azs}"]
  database_name      = "${var.db_name}"
  master_username    = "${var.db_user}"
  master_password    = "${var.db_snapshot_identifier == "" ? var.db_password : "" }"	
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
  from_port      = "${var.port}"
  to_port        = "${var.port}"
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
  description = "Access to DB port"
  vpc_id = "${data.aws_vpc.this.id}"

  ingress {
    from_port = "${var.port}"
    to_port = "${var.port}"
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
