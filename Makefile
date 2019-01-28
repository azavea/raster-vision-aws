include settings.mk

.PHONY: publish-container

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
		-e AWS_REGION=${AWS_REGION} \
		-w /usr/local/src \
		rastervision/packer \
		build packer/template-gpu.json

# For publishing a Docker image to ECR.
publish-container-gpu:
	$(eval ACCOUNT_ID=$(shell aws sts get-caller-identity --output text --query 'Account'))
	aws ecr get-login --no-include-email --region ${AWS_REGION} | bash;
	docker tag ${RASTER_VISION_GPU_IMAGE} \
		${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_GPU_IMAGE}:${ECR_IMAGE_TAG}
	docker push \
		${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_GPU_IMAGE}:${ECR_IMAGE_TAG}

publish-container-cpu:
	$(eval ACCOUNT_ID=$(shell aws sts get-caller-identity --output text --query 'Account'))
	aws ecr get-login --no-include-email --region ${AWS_REGION} | bash;
	docker tag ${RASTER_VISION_CPU_IMAGE} \
		${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_CPU_IMAGE}:${ECR_IMAGE_TAG}
	docker push \
		${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_CPU_IMAGE}:${ECR_IMAGE_TAG}

publish-container: publish-container-cpu publish-container-gpu
