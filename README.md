# Raster Vision AWS Batch runner setup

This repository contains the deployment code that sets up the necessary AWS resources to utilize the AWS Batch runner in [Raster Vision](https://rastervision.io). Deployment is driven by [Terraform](https://terraform.io/) and the [AWS Command Line Interface (CLI)](http://aws.amazon.com/cli/) through a local Docker Compose environment.

## Table of Contents ##

* [AWS Credentials](#aws-credentials)
* [Packer Image](#packer-docker-image)
* [AMI Creation](#ami-creation)
* [AWS Batch Resources](#aws-batch-resources)

## AWS Credentials ##

Using the AWS CLI, create an AWS profile for the target AWS environment. An example, naming the profile `raster-vision`:

```bash
$ aws --profile raster-vision configure
AWS Access Key ID [****************F2DQ]:
AWS Secret Access Key [****************TLJ/]:
Default region name [us-east-1]: us-east-1
Default output format [None]:
```

You will be prompted to enter your AWS credentials, along with a default region. These credentials will be used to authenticate calls to the AWS API when using Terraform and the AWS CLI.

## Packer Docker Image ##

You must ensure that you have the `rastervision/packer` Docker image.
From within the root directory of the repository, type `make packer-image` to build it.

## AMI Creation ##

This step uses packer to install nvidia-docker on the base ECS AMI
in order to run GPU jobs on AWS Batch.

### Configure the settings ###

Copy the `settings.mk.template` file to `settings.mk`, and fill out the following options:


| `AWS_BATCH_BASE_AMI`         | The AMI of the Deep Learning Base AMI (Amazon Linux) to use.                 |
|------------------------------|------------------------------------------------------------------------------|
| `AWS_ROOT_BLOCK_DEVICE_SIZE` | The size of the volume, in GiB, of the root device for the AMI.              |
| `AMI_ID`                     | The AMI ID that comes from the `make create-ami` step                        |
| `KEY_PAIR_NAME`              | The key pair name for the batch EC2 instances                                |
| `AWS_REGION`                 | The AWS region to use.                                                       |
| `RASTER_VISION_IMAGE`        | The raster vision image to use. e.g. quay.io/azavea/raster-vision:gpu-latest |
| `ECR_IMAGE`                  | The name for the ECR image                                                   |
| `ECR_IMAGE_TAG`              | The ECR image tag to use, that is the tag in ECR_IMAGE                       |

To find the latest Deep Learning Base AMI, search in th AMI section of your EC2 AWS console for
`Deep Learning Base AMI (Amazon Linux)`

### Create the AMI ###

Ensure that the AWS profile for the account you want to create the AMI in is set in your `AWS_PROFILE`
environment variable setting.

Then run:
```shell
> make create-ami
```

This will run packer, which will spin up an EC2 instance, install the necessary resources, create an AMI
off of the instance, and shut the instance down.

### Record the AMI ID ###

Be sure to record the AMI ID, which will be given in the last line of the output for `make create-ami`
on a successful run. Put this in the `settings.mk` as `AMI_ID`.

## AWS Batch ##

Create the AWS Batch computer environment, queue, and more by doing:

```shell
> make plan
> make apply
```

## Publish the Raster Vision container to ECS ##

Use

```shell
> make publish-container
```

to publish the raster-vision container to your ECR repository.
