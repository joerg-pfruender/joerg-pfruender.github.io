---
layout: post
title:  "Testing with SNS/SQS using Localstack in Docker"
date:   2020-01-25 13:15:00 +0100
categories: [software, docker, microservices, testing]
tags: [docker, localstack, sns, sqs, testing]
---

![Time](/assets/messages.jpg)

## REST vs. Messaging in Microservices

If you have a microservice architecture, you hopefully do not rely on REST only for inter-service communications.
If you only use HTTP and REST for inter-service communication you might end up with problems because latency and error probability will add up with every hop of your synchronous communication. In the beginning you won't realize it, but it will kill your system in the end.

You hopefully use some kind of asynchronous communication, maybe messaging.
And if you use messaging on the Amazon AWS Cloud you most likely use SNS and SQS.

## Collaboration Testing including SNS/SQS

But how can you test your microservices including the communication in your CI/CD-Pipeline?
Your build should not rely on internet connections, so you should not connect to the AWS Cloud during your CI-Tests. 

### localstack inside docker
Here comes [localstack&#8599;](https://localstack.cloud/) ([Github&#8599;](https://github.com/localstack/localstack))
They have provided some fake Amazon AWS services for testing.

You do not need to install it on your machine, there is a docker image available on [Docker Hub&#8599;](https://hub.docker.com/r/localstack/localstack/).

### How to bootstrap queues and topics
But before your test execution, you will need to setup the topics and queues.
How should you do that?
* During the test setup? 
* During the bootstrap of the service under test? 
* And who is responsible when testing the collaboration of two or more services?

What if the localstack docker container could just come up with all topics and queues "magically" preconfigured during its own startup?

Here is the solution:
If you map a directory into `/docker-entrypoint-initaws.d` of the localstack's docker-container volume it gets executed right after the start of the localstack container.

So I put an shell script inside the folder `localstack_setup` that bootstraps my topics and queues.
Then I map that `localstack_setup` folder containing the startup script into the `/docker-entrypoint-initaws.d` directory of the docker container.
  

    version: '3'
    services:
    
      localstack:
        image: localstack/localstack
        ports:
          - "4566"
        environment:
          - SERVICES=sns,sqs
          - DEBUG=1
          - DOCKER_HOST=unix:///var/run/docker.sock
          - HOSTNAME_EXTERNAL=localstack
        volumes:
          - ./localstack_setup:/docker-entrypoint-initaws.d/
          - /tmp/localstack:/tmp/localstack
          - /var/run/docker.sock:/var/run/docker.sock


### How to do the topic and queue configuration inside a startup script?

Thank you Gustavo Siqueira for providing some scripts how to set up those stuff [on your blog&#8599;](https://gugsrs.com/localstack-sqs-sns/)
We just need to create a shell script now.

0. AWS cli is already installed on localstack, no need to do that.
1. Create some functions to setup topics and queues:
    * get_all_queues
    * create_queue
    * get_all_topics
    * create_topic
    * link_queue_and_topic
    * guess_queue_arn_from_name
    
2. Call those functions to create as many topics and queues as you need and connect them. 


            #!/usr/bin/env bash
            
            set -euo pipefail
            
            # enable debug
            # set -x
          
            
            echo "configuring sns/sqs"
            echo "==================="
            # https://gugsrs.com/localstack-sqs-sns/
            LOCALSTACK_HOST=localhost
            AWS_REGION=us-east-1
            LOCALSTACK_DUMMY_ID=000000000000
            
            get_all_queues() {
                awslocal --endpoint-url=http://${LOCALSTACK_HOST}:4566 sqs list-queues
            }
            
            
            create_queue() {
                local QUEUE_NAME_TO_CREATE=$1
                awslocal --endpoint-url=http://${LOCALSTACK_HOST}:4566 sqs create-queue --queue-name ${QUEUE_NAME_TO_CREATE}
            }
            
            get_all_topics() {
                awslocal --endpoint-url=http://${LOCALSTACK_HOST}:4566 sns list-topics
            }
            
            create_topic() {
                local TOPIC_NAME_TO_CREATE=$1
                awslocal --endpoint-url=http://${LOCALSTACK_HOST}:4566 sns create-topic --name ${TOPIC_NAME_TO_CREATE}
            }
            
            link_queue_and_topic() {
                local TOPIC_ARN_TO_LINK=$1
                local QUEUE_ARN_TO_LINK=$2
                awslocal --endpoint-url=http://${LOCALSTACK_HOST}:4566 sns subscribe --topic-arn ${TOPIC_ARN_TO_LINK} --protocol sqs --notification-endpoint ${QUEUE_ARN_TO_LINK}
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


When you look at the code, you will see, that bash scripting is not my programming mother tongue. I'm more a java guy. So if you have some improvements, I will be happy.

## One more thing

### Where am I? localhost or not?

When SQS clients ask for a queue, they will receive a URL of the queue.
Now localstack needs to know its own hostname. Is it localhost? Maybe... or not?

If your SQS clients live with localstack in the same docker network, then it's the container's host name inside the docker network.
In my docker-compose file it's `HOSTNAME_EXTERNAL=localstack`.

If your SQS clients live on the docker host it's `HOSTNAME_EXTERNAL=localhost` and you must expose your SQS port to the host.  
If you have a mixed scenario? 
Now you have a problem....

### inside _and_ outside docker networks

My constraints are:

* In CI/CD my clients and tests live inside the docker-compose network.
* On my workstation I sometimes need to debug from outside.

I've tried several solutions, and now I use this:

* I have a docker-compose.override.yml that exposes localstack's ports on the docker host. 

      version: '3'
      services:
    
          localstack:
            ports:
              - "4566:4566"
              
              
  My docker-compose.override.yml is mentioned in the `.gitignore` file so it will not make its way onto the build server.
* I have added 

        127.0.0.1       localstack
    
  to my `/etc/hosts` file.
  
Now I can use localstack from inside and outside the docker-compose network with no issues. Well it's kind of a bad hack, but until now, it works for me.

## Update

Since it is not easy to copy paste the bash script from this page, you can find in [a separate file&#8599;](https://github.com/joerg-pfruender/joerg-pfruender.github.io/blob/master/assets/setup_sns_sqs.sh), too.

2021-05-18 update for newer localstack versions

### more...
about localstack and docker: 
* [Three obstacles when testing lambdas with testcontainers and localstack](/software/testing/2020/09/27/localstack_and_lambda.html)
* [Debugging AWS Secrets Manager Credentials using Localstack](/software/docker/microservices/testing/2023/02/13/localstack_and_secretsmanager_samples.html)

[More about Testing](/collections/testautomation.html)

*Any comments or suggestions? Leave an issue or a pull request!*
