---
layout: post
title:  "Debugging AWS Secrets Manager Credentials using Localstack"
date:   2023-02-13 19:00:00 +0100
categories: [software, docker, microservices, testing]
tags: [docker, localstack, aws, secretsmanager, testing, java]
---

![key ring](/assets/keyring.jpg)
<small>Image by <a href="https://pixabay.com/users/takeshiiiit-49965/">Takeshi Hirano</a> via <a href="https://pixabay.com/">Pixabay</a></small>


During the last few days, I had a tough time debugging. My service did not want to startup because of missing credentials.

I tried different things. But I did not find out why the service failed.

In the end, I used localstack to debug the behaviour on my machine.

## localstack inside docker
I had written about localstack in some blog posts before; see [Testing with SNS/SQS using Localstack in Docker](/software/docker/microservices/testing/2020/01/25/Localstack_in_Docker.html).

[Localstack&#8599;](https://localstack.cloud/) ([Github&#8599;](https://github.com/localstack/localstack))
is a service for faking [Amazon AWS](https://aws.amazon.com) services for testing.

You do not need to install it on your machine; there is a docker image available on [Docker Hub&#8599;](https://hub.docker.com/r/localstack/localstack/).

The easiest way to consume it: Use the provided [docker-compose.yml](https://github.com/localstack/localstack/blob/master/docker-compose.yml). 
You just need to specify which service you want to use:

`SERVICES=secretsmanager`
  
Putting things together:

    
        version: "3.8"
        
        services:
          localstack:
            container_name: "${LOCALSTACK_DOCKER_NAME-localstack_main}"
            image: localstack/localstack
            ports:
              - "127.0.0.1:4566:4566"            # LocalStack Gateway
              - "127.0.0.1:4510-4559:4510-4559"  # external services port range
            environment:
              - DEBUG=1
              - SERVICES=secretsmanager
              - LAMBDA_EXECUTOR=${LAMBDA_EXECUTOR-}
              - DOCKER_HOST=unix:///var/run/docker.sock
            volumes:
              - "${LOCALSTACK_VOLUME_DIR:-./volume}:/var/lib/localstack"
              - "/var/run/docker.sock:/var/run/docker.sock"



## How to setup the credentials

### configure aws profile

In recent versions, localstack only plays well when using the `us-east-1` region:

~./aws/config
```
[profile localstack]
region = us-east-1
```

Localstack does not evaluate credentials, so you can just set some dummy values:

~./aws/credentials
```
[localstack]
aws_access_key=dummy
aws_secret_access_key=dummy
```

### create/save/read credentials using awscli

sample requests:

```bash

aws secretsmanager create-secret --endpoint-url=http://localhost:4566 --profile localstack --name my-secret-name

aws secretsmanager put-secret-value --endpoint-url=http://localhost:4566 --profile localstack --secret-id my-secret-name '{"key":"value"}'

aws secretsmanager get-secret-value --endpoint-url=http://localhost:4566 --profile localstack --secret-id my-secret-name 

```

As an alternative, you could also use [awslocal](https://pypi.org/project/awscli-local/), but I prefer using the endpoint parameter.

#### configure java

When using java to access the credentials, you should make sure that it connects to localstack:

Java VM Options:
`-Daws.secretsmanager.endpoint=http://localhost:4566 -Daws.accessKeyId=dummy -Daws.secretKey=dummy -Daws.region=us-east-1`

Environment:

`AWS_PROFILE=localstack`

Happy Testing/Debugging!

### more...
about localstack and docker: 
* [Three obstacles when testing lambdas with testcontainers and localstack](/software/testing/2020/09/27/localstack_and_lambda.html)
* [Testing with SNS/SQS using Localstack in Docker](/software/docker/microservices/testing/2020/01/25/Localstack_in_Docker.html)
  
### legal notice
Amazon AWS is a [trademarks&#8599;](https://aws.amazon.com/trademark-guidelines/) of Amazon.com

[More about Testing](/collections/testautomation.html)

*Any comments or suggestions? Leave an issue or a pull request!*
