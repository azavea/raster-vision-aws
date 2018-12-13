variable "project" {
  default = "Raster Vision"
}

variable "environment" {
  default = "Staging"
}

variable "aws_region" {
  default = "us-east-1"
}

variable "batch_ami_id" {}

variable "aws_key_name" {}

variable "batch_spot_fleet_bid_precentage" {
  default = "100"
}

variable "batch_min_vcpus" {
  default = 0
}

variable "batch_desired_vcpus" {
  default = 0
}

variable "batch_max_vcpus" {
  default = 80
}

variable "batch_instance_types" {
  type = "list",
  default = [ "p3.2xlarge"]
}

variable "batch_job_definition_name" {
  default = "raster-vision-gpu"
}

variable "batch_instance_vcpus" {
  default = 8
}

variable "batch_instance_memory" {
  default = 55000
}

variable "aws_batch_service_role_policy_arn" {
  default = "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"
}

variable "ecr_repository_name" {
  default = "rastervision"
}

variable "ecr_image_tag" {
  default = "latest"
}

variable "aws_spot_fleet_service_role_policy_arn" {
  default = "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetTaggingRole"
}

variable "subnet_ids" {
  type        = "list"
  description = "A list of IDs of subnets in which to launch Batch instances. All subnets must exist in the same VPC."
}
