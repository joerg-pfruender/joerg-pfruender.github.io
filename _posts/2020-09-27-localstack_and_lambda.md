---
layout: post
title:  "Three obstacles when testing lambdas with testcontainers and localstack"
date:   2020-09-27 19:00:00 +0200
categories: [software, testing]
tags: [software, testing, serverless, aws, lambda, localstack, testcontainers]
---

I am developing a piece of software that should be deployed as a [AWS lambda&#8599;](https://aws.amazon.com/lambda/) function and I wanted to test it.
Some people just write unit tests for the lambda and they think, that's enough.

Not me:
- What about serialization and deserialization of event object?
- How does the lambda behave? Does the whole call chain work?

Some just deploy their lambdas to [Amazon AWS&#8599;](https://aws.amazon.com) and do manual tests in the cloud. But I my tests to be a part of my [ci&#8599;](https://en.wikipedia.org/wiki/Continuous_integration) run.

I am used to [localstack&#8599;](https://localstack.cloud/) ([Github&#8599;](https://github.com/localstack/localstack)) and [testcontainers&#8599;](https://www.testcontainers.org/).

Now I want to test my lambda using a docker-compose Testcontainer with localstack and some other services.
Then I use a java client to configure the lambda on localstack.

On that way I have encountered three problems and here are my solutions to them:

## 1. Networking

docker-compose starts it's services in one docker network. Localstack starts lambdas by spawning a new docker container.
But that docker container does not live in the docker-compose's network. So my lambda cannot simply connect to a service or database in my docker-compose environment.

### Solution

1. Create a new docker network.

   With Testcontainers it's as simple as `Network shared = Network.SHARED; shared.getId();`

2. Attach docker-compose and lambdas to this network.
   
   First I need to get the name of the network. I used a hack to do this:
   
   ```
   networkName = ((NetworkImpl)shared).getName();
   ```

   Then I write a `docker-compose.override.yml`:
   - docker-compose network is an "external" network with the name that I have got using the statement above.
   - lambdas will be spawned in a network defined by the value of the 'LAMBDA_DOCKER_NETWORK' environment variable.

   ```
   version: '3.7'
   
   services:
     database:
       networks:
         - sharednet
   
     localstack:
       environment:
         - LAMBDA_DOCKER_NETWORK=<networkName>
       networks:
         - sharednet
   
   networks:
     sharednet:
       external: true
       name: <networkName>
  
   ```
   Now all services can talk to each other.
   
   Still have troubles with node.js lambdas connecting to other services with some error message containing `getaddrinfo ENOTFOUND`? 
   Maybe node.js tries dns resolution. And I think you do not have a dns server inside your docker-compose network telling the ip address of your database from the its dns name. 
   Get the IPs of the services and configure your node.js lambda using ip addresses instead of hostnames. 

## 2. Configure SQS to call Lambda

I can easily configure my lambda to be called on events in a sqs queue, just by using `createEventSourceMapping` from the aws lambda library.
But how can I get the "arn" of my localstack lambda?

### Solution

It took me some hours to find the documentation, but in the end it's just:

```
  String getQueueArn(AmazonSQS sqsClient, String queueUrl) {
      return sqsClient.getQueueAttributes(new GetQueueAttributesRequest(queueUrl).withAttributeNames("QueueArn")).getAttributes().get("QueueArn");
  }
```

Just one thing: For a queue living in localstack in a docker container getting the "correct" sqs queue url is not trivial. The hostname can be configured using the `HOSTNAME_EXTERNAL` environment variable of localstack's container.
But the hostname inside the docker-compose network and the hostname outside the docker-compose network can be different. And the port can be different, too.
So, in my case, I replaced the hostname in the original queue url with the hostname that I got from testcontainers' `getServiceHost` function.  

## 3. Logging

In the end everything seemed fine, but I could not find any log statements of the code that I wanted to run inside the lambda.
 
Does it get a request? Does it do anything?

Eventually I realised the problem: The lambda is running in a new container, that is spawned by localstack.
But localstack does not create the lambda container right after the lambda configuration.
It creates the lambda container, when the lambda needs to be invoked for the first time.  
And my testcontainers' log consumer cannot know about that new container.

After realising that, the solution was easy:

### Solution:

I use the docker client, that comes with the testcontainers library:
```groovy
DockerClientFactory.instance().client()
``` 

Then I poll for the existence of a container with the expected name. When I find it, then I attach logging to it:

```groovy
    void attachLogger(Container container) {
        dockerClient.logContainerCmd(container.getId())
                .withFollowStream(true)
                .withStdOut(true)
                .withStdErr(true)
                .exec(new ResultCallbackTemplate<>() {
                    @Override
                    public void onNext(Frame frame) {
                        LOGGER.info(frame.toString());
                    }
                });
    }
```

Now I can run the code and see the log messages. 
I hope that I can later share a complete how-to source code.

## Update 2020 Nov 20

## Obstacle No 4: hanging containers

Testcontainers has a really good way to make sure, that all containers are stopped after testing.
But if localstack start a lambda container, then testcontainers does not know about that.
So sometimes it happens that the lambda container remains running after the test has finished.
I have not found a really good solution to that problem.
But I have found a way to mitigate the problem:

### Solution:
Testcontainers comes with a dependency to the java-docker-api and using this you can find running containers, e.g.:

```groovy
    public List<Container> findContainersByImageName(String containerImageNameSearchString) {
        List<Container> containers = DockerClientFactory.instance().client().listContainersCmd().exec();
        return containers.stream().filter(it -> it.getImage().contains(containerImageNameSearchString)).collect(Collectors.toList());
    }

    ...

    findContainersByImageName("lambci/lambda:java11")

```

You can later filter them by network in order to find and stop the lambda container that was spawned by your localstack instance or just stop all really old containers that are still running.


### more information
If you want to have more information about localstack or testcontainers, look at my blog posts on [localstack](/software/docker/microservices/testing/2020/01/25/Localstack_in_Docker.html) and on [testcontainers](/software/testing/2020/03/29/testcontainers.html).

### legal notice
Amazon AWS and AWS lambda are [trademarks&#8599;](https://aws.amazon.com/trademark-guidelines/) of Amazon.com

*Any comments or suggestions? Leave an issue or a pull request!*
