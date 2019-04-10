TAG ?= pahud/s3-global2cn:latest
CONTAINER_NAME ?= s3-global2cn
SQS_URL ?= 'https://sqs.ap-northeast-1.amazonaws.com/903779448426/global2china'
MSG_BODY ?= s3://pahud-tmp-ap-northeast-1/1M
AWS_REGION ?= ap-northeast-1

.PHONY: build run clear dry-run push
build:
	@docker build -t $(TAG) .
	
push:
	@docker push $(TAG)
	
run:
	@docker run --name $(CONTAINER_NAME) \
	-v $(HOME)/.aws:/root/.aws \
	--env-file envfile \
	--rm -ti $(TAG) /bin/bash /root/run.sh
	
	
dry-run:
	@aws --region $(AWS_REGION) sqs send-message --queue-url $(SQS_URL) \
	--message-body $(MSG_BODY)

clear:
	@docker rm -f $(CONTAINER_NAME)