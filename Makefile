include settings.mk

.PHONY: publish-images

# For publishing a Docker image to ECR.
publish-image-tf-gpu:
	$(eval ACCOUNT_ID=$(shell aws sts get-caller-identity --output text --query 'Account'))
	aws ecr get-login --no-include-email --region ${AWS_REGION} | bash;
	docker tag ${RASTER_VISION_TF_GPU_IMAGE} \
		${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_TF_GPU_IMAGE}:${ECR_IMAGE_TAG}
	docker push \
		${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_TF_GPU_IMAGE}:${ECR_IMAGE_TAG}

publish-image-tf-cpu:
	$(eval ACCOUNT_ID=$(shell aws sts get-caller-identity --output text --query 'Account'))
	aws ecr get-login --no-include-email --region ${AWS_REGION} | bash;
	docker tag ${RASTER_VISION_TF_CPU_IMAGE} \
		${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_TF_CPU_IMAGE}:${ECR_IMAGE_TAG}
	docker push \
		${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_TF_CPU_IMAGE}:${ECR_IMAGE_TAG}

publish-image-pytorch:
	$(eval ACCOUNT_ID=$(shell aws sts get-caller-identity --output text --query 'Account'))
	aws ecr get-login --no-include-email --region ${AWS_REGION} | bash;
	docker tag ${RASTER_VISION_PYTORCH_IMAGE} \
		${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_PYTORCH_IMAGE}:${ECR_IMAGE_TAG}
	docker push \
		${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_PYTORCH_IMAGE}:${ECR_IMAGE_TAG}

publish-images: publish-image-tf-cpu publish-image-tf-gpu publish-image-pytorch
