#
# Elastic Container Repository resources
#
resource "aws_ecr_repository" "rastervision" {
  name = "${var.ecr_repository_name}"
}
