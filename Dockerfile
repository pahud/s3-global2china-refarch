FROM amazonlinux:2

RUN yum update -y && yum install -y jq unzip curl; \
    curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"; \
    unzip awscli-bundle.zip; \
    ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws; \
    rm -rf awscli-bundle*


ADD run.sh /root/

