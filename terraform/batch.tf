#
# Batch resources
#
resource "aws_batch_compute_environment" "rastervision" {
  depends_on = ["aws_iam_role_policy_attachment.batch_policy"]

  compute_environment_name = "rasterVisionBatch${var.environment}ComputeEnvironment"
  type                     = "MANAGED"
  state                    = "ENABLED"
  service_role             = "${aws_iam_role.container_instance_batch.arn}"

  compute_resources {
    type           = "SPOT"
    bid_percentage = "${var.batch_spot_fleet_bid_precentage}"
    ec2_key_pair   = "${var.aws_key_name}"
    image_id       = "${var.batch_ami_id}"

    min_vcpus     = "${var.batch_min_vcpus}"
    desired_vcpus = "${var.batch_desired_vcpus}"
    max_vcpus     = "${var.batch_max_vcpus}"

    spot_iam_fleet_role = "${aws_iam_role.container_instance_spot_fleet.arn}"
    instance_role       = "${aws_iam_role.container_instance_ec2.arn}"

    instance_type = [
      "${var.batch_instance_types}",
    ]

    security_group_ids = [
      "${aws_security_group.container_instance.id}",
    ]

    subnets = "${var.subnet_ids}"

    tags {
      Name               = "Raster Vision BatchWorker"
      ComputeEnvironment = "Raster Vision"
      Project            = "${var.project}"
      Environment        = "${var.environment}"
    }
  }
}

resource "aws_batch_job_queue" "rastervision" {
  name                 = "rasterVisionQueue${var.environment}"
  priority             = 1
  state                = "ENABLED"
  compute_environments = ["${aws_batch_compute_environment.rastervision.arn}"]
}

data "template_file" "batch_job_definition" {
  template = "${file("job-definitions/raster-vision.json")}"

  vars {
    image_name = "${aws_ecr_repository.rastervision.repository_url}:${var.ecr_image_tag}"
    vcpus = "${var.batch_instance_vcpus}"
    memory = "${var.batch_instance_memory}"
  }
}

resource "aws_batch_job_definition" "rastervision" {
  name = "${var.batch_job_definition_name}"
  type = "container"
  container_properties = "${data.template_file.batch_job_definition.rendered}"
}
