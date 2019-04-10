#!/bin/bash

SQS_URL=${SQS_URL-undefined}
MAX_MSG=${MAX_MSG-1}
WAIT_TIME_SECONDS=${WAIT_TIME_SECONDS-10}
AWS_REGION=${AWS_REGION-ap-northeast-1}
SQS_OUTFILE=${SQS_OUTFILE-/tmp/sqs.out}


awscn="AWS_REGION=cn-north-1 AWS_DEFAULT_REGION=cn-north-1 AWS_PROFILE=cn aws"


init() {
    aws configure --profile=cn set aws_access_key_id $cn_aws_ak
    aws configure --profile=cn set aws_secret_access_key $cn_aws_sk
    aws configure --profile=cn set region cn-north-1
    aws configure --profile=cn set default.region cn-north-1
    # eval $awscn sts get-caller-identity
}


poll(){
    echo "start SQS polling...(wait $WAIT_TIME_SECONDS seconds)"
    aws --region ${AWS_REGION} \
    sqs receive-message \
    --queue-url ${SQS_URL} \
    --max-number-of-messages ${MAX_MSG} \
    --wait-time-seconds ${WAIT_TIME_SECONDS} > "$SQS_OUTFILE"
    # --query 'Messages[*].Body' --output text
}

deletemsg(){
    echo "deleting msg"
    aws --region ${AWS_REGION} \
    sqs delete-message \
    --queue-url ${SQS_URL} \
    --receipt-handle "$1"
}

clone(){
    tmpfile=$(mktemp)
    newpath=$(echo $1 | sed -e 's/pahud-tmp-ap-northeast-1/pahud-tmp-cn-north-1/')
    echo "downloading $1" && \
    aws s3 cp "${1}" $tmpfile && \
    echo "uploading to $newpath" && \
    # AWS_REGION=cn-north-1 AWS_DEFAULT_REGION=cn-north-1 \
    # AWS_PROFILE=cn \
    eval $awscn s3 cp "$tmpfile" "$newpath" && \
    rm -f $tmpfile && return 0 || return 1
}

cleanup(){
    rm -f $SQS_OUTFILE
}

init

while true
do
    cleanup
    poll
    if [ -s $SQS_OUTFILE ]; then
        body=$(cat $SQS_OUTFILE | jq -r .Messages[0].Body)
        handle=$(cat $SQS_OUTFILE  | jq -r .Messages[0].ReceiptHandle)
        echo $body
        clone $body && deletemsg "$handle" && cleanup
    fi
    sleep 0.1
done

exit 0