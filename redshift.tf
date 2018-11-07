
resource "aws_redshift_subnet_group" "my_redshift_subnet_group" {
  name       = "${var.name}-redshift-subnet-group"
  subnet_ids = ["${module.heroku_aws_vpc.private_subnet_id}"]
  tags {
    environment = "Production"
  }
}

# https://devcenter.heroku.com/articles/private-space-peering#setting-up-security-groups
resource "aws_security_group" "redshift_sg" {
  name   = "${var.name}-redshift-sg"
  vpc_id = "${module.heroku_aws_vpc.id}"

  # Allow Heroku Private Space Dynos to connect to redshift cluster via any protocols
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["${data.heroku_space_peering_info.default.dyno_cidr_blocks.0}",
                      "${data.heroku_space_peering_info.default.dyno_cidr_blocks.1}",
                      "${data.heroku_space_peering_info.default.dyno_cidr_blocks.2}",
                      "${data.heroku_space_peering_info.default.dyno_cidr_blocks.3}"]
  }
}

# adding route as specified from docs:
# https://docs.aws.amazon.com/vpc/latest/peering/vpc-peering-routing.html
# https://devcenter.heroku.com/articles/private-space-peering#option-1-add-one-route-for-entire-private-space-cidr-block-recommended
resource "aws_route" "private_vpc_route" {
  route_table_id            = "${module.heroku_aws_vpc.private_route_table_id}"
  destination_cidr_block    = "${data.heroku_space_peering_info.default.vpc_cidr}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.request.id}"
}


# Single Node Redshift cluster 
resource "aws_redshift_cluster" "tf_redshift_cluster" {
  cluster_identifier  = "${var.name}-tf-redshift-cluster"
  database_name       = "${var.redshift_dbname}"
  master_username     = "${var.redshift_username}"
  master_password     = "${var.redshift_password}"
  node_type           = "dc1.large"
  cluster_type        = "single-node"
  publicly_accessible = "false" 
  skip_final_snapshot = "true"
  cluster_subnet_group_name = "${aws_redshift_subnet_group.my_redshift_subnet_group.name}"
  vpc_security_group_ids  = ["${aws_security_group.redshift_sg.id}"]
}



