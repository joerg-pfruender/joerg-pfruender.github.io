#!/usr/bin/env bash

# enable debug
# set -x

echo "installing jq"
apk add jq

echo "configuring aws-cli"
aws_dir="/root/.aws"
if [[ -d "$aws_dir" ]]
then
    echo "'${aws_dir}' already exists, skipping aws configuration with dummy credentials"
else
   mkdir /root/.aws

    # https://linuxhint.com/bash-heredoc-tutorial/
    NewFile=aws-dummy-credentials-temp
    (
cat <<'AWSDUMMYCREDENTIALS'
[default]
AWS_ACCESS_KEY_ID = dummy
AWS_SECRET_ACCESS_KEY = dummy
AWSDUMMYCREDENTIALS
    ) > ${NewFile}
    mv aws-dummy-credentials-temp /root/.aws/credentials

    NewFile=aws-config-temp
    (
cat <<'AWSCONFIG'
[default]
region = eu-central-1
AWSCONFIG
    ) > ${NewFile}
    mv aws-config-temp /root/.aws/config

fi

echo "configuring sns/sqs"
echo "==================="
# https://gugsrs.com/localstack-sqs-sns/
LOCALSTACK_HOST=localhost
AWS_REGION=eu-central-1
LOCALSTACK_DUMMY_ID=000000000000

get_all_queues() {
    aws --endpoint-url=http://${LOCALSTACK_HOST}:4576 sqs list-queues
}


create_queue() {
    local QUEUE_NAME_TO_CREATE=$1
    aws --endpoint-url=http://${LOCALSTACK_HOST}:4576 sqs create-queue --queue-name ${QUEUE_NAME_TO_CREATE}
}

get_all_topics() {
    aws --endpoint-url=http://${LOCALSTACK_HOST}:4575 sns list-topics
}

create_topic() {
    local TOPIC_NAME_TO_CREATE=$1
    aws --endpoint-url=http://${LOCALSTACK_HOST}:4575 sns create-topic --name ${TOPIC_NAME_TO_CREATE} | jq -r '.TopicArn'
}

link_queue_and_topic() {
    local TOPIC_ARN_TO_LINK=$1
    local QUEUE_ARN_TO_LINK=$2
    aws --endpoint-url=http://${LOCALSTACK_HOST}:4575 sns subscribe --topic-arn ${TOPIC_ARN_TO_LINK} --protocol sqs --notification-endpoint ${QUEUE_ARN_TO_LINK}
}

guess_queue_arn_from_name() {
    local QUEUE_NAME=$1
    echo "arn:aws:sns:${AWS_REGION}:${LOCALSTACK_DUMMY_ID}:$QUEUE_NAME"
}

QUEUE_NAME="queue123"
TOPIC_NAME="topic56789"

echo "creating topic $TOPIC_NAME"
TOPIC_ARN=$(create_topic ${TOPIC_NAME})
echo "created topic: $TOPIC_ARN"

echo "creating queue $QUEUE_NAME"
QUEUE_URL=$(create_queue ${QUEUE_NAME})
echo "created queue: $QUEUE_URL"
QUEUE_ARN=$(guess_queue_arn_from_name $QUEUE_NAME)

echo "linking topic $TOPIC_ARN to queue $QUEUE_ARN"
LINKING_RESULT=$(link_queue_and_topic $TOPIC_ARN $QUEUE_ARN)
echo "linking done:"
echo "$LINKING_RESULT"

echo "all topics are:"
echo "$(get_all_topics)"

echo "all queues are:"
echo "$(get_all_queues)"



