# Raster Vision AWS Batch runner setup

This repository contains the deployment code that sets up the necessary AWS resources to utilize the AWS Batch runner in [Raster Vision](https://rastervision.io).

Note: The `master` branch of this repo should be used in conjunction with the `master` branch (or `latest` Docker image tag) of [Raster Vision](https://github.com/azavea/raster-vision)
which contains the latest changes. For versions of this repo that correspond to stable, released versions of Raster Vision, see:
* [0.9](https://github.com/azavea/raster-vision-aws/tree/0.9)

Using Batch is advantageous because it starts and stops instances automatically and runs jobs sequentially or in parallel according to the dependencies between them. In addition, this deployment sets up distinct CPU and GPU resources and utilizes spot instances, which is more cost-effective than always using a GPU on-demand instance. Deployment is driven via the AWS console using a [CloudFormation template](https://aws.amazon.com/cloudformation/aws-cloudformation-templates/). This AWS Batch setup is an "advanced" option that assumes some familiarity with [Docker](https://docs.docker.com/), AWS [IAM](https://docs.aws.amazon.com/IAM/latest/UserGuide/introduction.html), [named profiles](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html), [availability zones](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html), [EC2](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/concepts.html), [ECR](https://docs.aws.amazon.com/AmazonECR/latest/userguide/what-is-ecr.html), [CloudFormation](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/Welcome.html), and [Batch](https://docs.aws.amazon.com/batch/latest/userguide/what-is-batch.html).

## Table of Contents ##

* [AWS Account Setup](#aws-account-setup)
* [AWS Credentials](#aws-credentials)
* [Deploying Batch resources](#deploying-batch-resources)
* [Update Raster Vision configuration](#update-raster-vision-configuration)

## AWS Account Setup ##

In order to setup Batch using this repo, you will need to setup your AWS account so that:
* you have either root access to your AWS account, or an IAM user with admin permissions. It may be possible with less permissions, but we haven't figured out how to do this yet after some experimentation.
* you have the ability to launch P2 or P3 instances which have GPUs. In the past, it was necessary to open a support ticket to request access to these instances. You will know if this is the case if the Packer job fails when trying to launch the instance.
* you have requested permission from AWS to use availability zones outside the USA if you would like to use them. (New AWS accounts can't launch EC2 instances in other AZs by default.) If you are in doubt, just use us-east-1.

## AWS Credentials ##

Using the AWS CLI, create an AWS profile for the target AWS environment. An example, naming the profile `raster-vision`:

```bash
$ aws --profile raster-vision configure
AWS Access Key ID [****************F2DQ]:
AWS Secret Access Key [****************TLJ/]:
Default region name [us-east-1]: us-east-1
Default output format [None]:
```

You will be prompted to enter your AWS credentials, along with a default region. The Access Key ID and Secret Access Key can be retrieved from the IAM console. These credentials will be used to authenticate calls to the AWS API when using Packer and the AWS CLI.

## Deploying Batch resources ##

To deploy AWS Batch resources using AWS CloudFormation, start by logging into your AWS console. Then, follow the steps below:

- Navigate to `CloudFormation > Create Stack`
- In the `Choose a template field`, select `Upload a template to Amazon S3` and upload the template in `cloudformation/template.yml`
- `Prefix`: If you are setting up multiple RV stacks within an AWS account, you need to set a prefix for namespacing resources. Otherwise, there will be name collisions with any resources that were created as part of another stack.
- Specify the following required parameters:
    - `Stack Name`: The name of your CloudFormation stack
    - `VPC`: The ID of the Virtual Private Cloud in which to deploy your resource. Your account should have at least one by default.
    - `Subnets`: The ID of any subnets that you want to deploy your resources into. Your account should have at least two by default; make sure that the subnets you select are in the VPC that you chose by using the AWS VPC console, or else CloudFormation will throw an error. (Subnets are tied to availability zones, and so affect spot prices.) In addition, you need to choose subnets that are available for the instance type you have chosen. To find which subnets are available, go to Spot Pricing History in the EC2 console and select the instance type. Then look up the availability zones that are present in the VPC console to find the corresponding subnets. ![spot availability zones for p3 instances](/docs/images/spot-azs.png)
    - `SSH Key Name`: The name of the SSH key pair you want to be able to use to shell into your Batch instances. If you've created an EC2 instance before, you should already have one you can use; otherwise, you can create one in the EC2 console. *Note: If you decide to create a new one, you will need to log out and then back in to the console before creating a Cloudformation stack using this key.*
    - `Instance Types`: Provide the instance types you would like to use. (For GPUs, `p3.2xlarge` is approximately 4 times the speed for 4 times the price.)
- Adjust any preset parameters that you want to change (the defaults should be fine for most users) and click `Next`.
    - Advanced users: If you plan on modifying Raster Vision and would like to publish a custom image to run on Batch, you will need to specify (Tensorflow CPU, Tensorflow GPU, and PyTorch) ECR repo names and a tag name to use for both. Note that the repo names cannot be the same as the Stack name (the first field in the UI) and cannot be the same as any existing ECR repo names. If you are in a team environment where you are sharing the AWS account, the repo names should contain an identifier such as your username.
- Accept all default options on the `Options` page and click `Next`
- Accept `I acknowledge that AWS CloudFormation might create IAM resources with custom names` on the `Review` page and click `Create`
- Watch your resources get deployed!

### Optional: Publish local Raster Vision images to ECR

If you setup ECR repositories during the CloudFormation setup (the "advanced user" option), then you will need to follow this step, which publishes local Raster Vision images to those ECR repositories. Every time you make a change to your local Raster Vision images and want to use those on Batch, you will need to run this step.

Run `./docker/build` in the main Raster Vision repo to build local copies of the Tensorflow CPU, Tensorflow GPU, and PyTorch images.

In `settings.mk`, fill out the options shown in the table below.

| Variable         | Description                 |
|------------------------------|------------------------------------------------------------------------------|
| `RASTER_VISION_TF_CPU_IMAGE`        | The local Raster Vision TF CPU image to use.
| `RASTER_VISION_TF_GPU_IMAGE`        | The local Raster Vision TF GPU image to use.
| `RASTER_VISION_PYTORCH_GPU_IMAGE`   | The local Raster Vision PyTorch image to use.
| `ECR_TF_CPU_IMAGE`                  | The name of the ECR TF CPU image
| `ECR_TF_GPU_IMAGE`                  | The name of the ECR TF GPU image
| `ECR_PYTORCH_IMAGE`                  | The name of the ECR PYTORCH image
| `ECR_IMAGE_TAG`              | The ECR image tag to use, that is the tag in ECR_TF_CPU_IMAGE,ECR_TF_GPU_IMAGE, and ECR_PYTORCH_IMAGE |

Run `make publish-images` to publish the images to your ECR repositories.

## Update Raster Vision configuration

Finally, make sure to update your [Raster Vision configuration](https://docs.rastervision.io/en/latest/setup.html#setting-up-aws-batch) with the Batch resources that were created.
