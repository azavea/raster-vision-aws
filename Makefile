include settings.mk

packer-image:
	docker build -t rastervision/packer -f Dockerfile.packer .

validate-packer-template:
	docker run --rm -it \
		-v ${PWD}/:/usr/local/src \
		-v ${HOME}/.aws:/root/.aws:ro \
		-e AWS_PROFILE=${AWS_PROFILE} \
		-e AWS_BATCH_BASE_AMI=${AWS_BATCH_BASE_AMI} \
		-e AWS_ROOT_BLOCK_DEVICE_SIZE=${AWS_ROOT_BLOCK_DEVICE_SIZE} \
		-w /usr/local/src \
		rastervision/packer \
		validate packer/template-gpu.json

create-image: validate-packer-template
	docker run --rm -it \
		-v ${PWD}/:/usr/local/src \
		-v ${HOME}/.aws:/root/.aws:ro \
		-e AWS_PROFILE=${AWS_PROFILE} \
		-e AWS_BATCH_BASE_AMI=${AWS_BATCH_BASE_AMI} \
		-e AWS_ROOT_BLOCK_DEVICE_SIZE=${AWS_ROOT_BLOCK_DEVICE_SIZE} \
		-w /usr/local/src \
		rastervision/packer \
		build packer/template-gpu.json

terraform-init:
	cd terraform && \
		terraform init;


plan: terraform-init
	cd terraform && \
		terraform plan \
			-var="batch_ami_id=${AMI_ID}" \
			-var="aws_key_name=${KEY_PAIR_NAME}" \
			-var="aws_region=${AWS_REGION}" \
			-var="ecr_image_tag=${ECR_IMAGE_TAG}" \
			-var="subnet_ids=${SUBNET_IDS}" \
			-out="raster-vision.tfplan";

apply:
	cd terraform && \
		terraform apply "raster-vision.tfplan";

destroy:
	cd terraform && \
		terraform destroy \
			-var="batch_ami_id=${AMI_ID}" \
			-var="aws_key_name=${KEY_PAIR_NAME}" \
			-var="aws_region=${AWS_REGION}" \
			-var="ecr_image_tag=${ECR_IMAGE_TAG}" \
			-var="subnet_ids=${SUBNET_IDS}";

publish-container:
	$(eval ACCOUNT_ID=$(shell aws sts get-caller-identity --output text --query 'Account'))
	aws ecr get-login --no-include-email --region ${AWS_REGION} | bash;
	docker tag ${RASTER_VISION_IMAGE} \
		${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_IMAGE}:${ECR_IMAGE_TAG}
	docker push \
		${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_IMAGE}:${ECR_IMAGE_TAG}
