#
# Security group resources
#
resource "aws_security_group" "container_instance" {
  vpc_id = "${data.aws_subnet.first.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 6006
    to_port     = 6006
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "sgRasterVisionContainerInstance"
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }
}

data "aws_subnet" "first" {
  id = "${var.subnet_ids[0]}"
}
