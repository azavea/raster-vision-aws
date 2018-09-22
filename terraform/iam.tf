#
# Batch IAM resources
#
data "aws_iam_policy_document" "container_instance_batch_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["batch.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "container_instance_batch" {
  name               = "rasterVision${var.environment}ServiceRole"
  assume_role_policy = "${data.aws_iam_policy_document.container_instance_batch_assume_role.json}"
}

resource "aws_iam_role_policy_attachment" "batch_policy" {
  role       = "${aws_iam_role.container_instance_batch.name}"
  policy_arn = "${var.aws_batch_service_role_policy_arn}"
}

#
# Container Instance IAM resources
#
data "aws_iam_policy_document" "container_instance_ec2_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "container_instance_ec2" {
  name               = "rasterVision${var.environment}ContainerInstanceProfile"
  assume_role_policy = "${data.aws_iam_policy_document.container_instance_ec2_assume_role.json}"
}

resource "aws_iam_role_policy_attachment" "ec2_service_role" {
  role       = "${aws_iam_role.container_instance_ec2.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "s3_service_role" {
  role       = "${aws_iam_role.container_instance_ec2.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_instance_profile" "container_instance" {
  name = "${aws_iam_role.container_instance_ec2.name}"
  role = "${aws_iam_role.container_instance_ec2.name}"
}

#
# Spot Fleet IAM resources
#
data "aws_iam_policy_document" "container_instance_spot_fleet_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["spotfleet.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "container_instance_spot_fleet" {
  name               = "rasterVisionFleet${var.environment}ServiceRole"
  assume_role_policy = "${data.aws_iam_policy_document.container_instance_spot_fleet_assume_role.json}"
}

resource "aws_iam_role_policy_attachment" "spot_fleet_policy" {
  role       = "${aws_iam_role.container_instance_spot_fleet.name}"
  policy_arn = "${var.aws_spot_fleet_service_role_policy_arn}"
}
