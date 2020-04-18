---
layout: post
title:  "docker-compose and gradle"
date:   2020-03-29 22:50:00 +0200
categories: [software, testing]
tags: [software, java, docker-compose, gradle]
---

Some weeks ago I have posted some thoughts on [Testcontainers](https://joerg-pfruender.github.io/software/testing/2020/03/29/testcontainers.html).
When dealing with docker-compose there is a way, that I prefer over using testcontainers.

## divide tests in unit tests and integration tests

Personally I like the [maven&#8599;](http://maven.apache.org/) style of testing (although there are some other things in maven that I really hate).
It divides testing into several [phases&#8599;](https://maven.apache.org/ref/3.6.3/maven-core/lifecycles.html), that really make sense:
  
* unit-tests: perform all tests that are easy to run because they have mocked dependencies.
* pre-integration-test: setup a test fixture for the integration tests
* integration-test: perform all the integration tests
* post-integration-test: teardown the test fixture

I like to do testing like this with gradle as well and [Petri Kainulainen explains how to do it&#8599;](https://www.petrikainulainen.net/programming/gradle/getting-started-with-gradle-integration-testing/).

## docker-compose gradle plugin

And for this scenario, I prefer the [docker-compose gradle plugin&#8599;](https://github.com/avast/gradle-docker-compose-plugin).

### build configuration

example docker-compose.yml

    version: '3'
    
    services:
      mysql:
        image: mysql:8.0.16
        ports:
          - '3306'


example gradle.build

    task integrationTest(type: Test) {
        description = 'IntegrationTest'
        group = 'verification'
    
        useJUnitPlatform {
            includeTags 'integrationTest'
        }
    
        dependsOn compileTestJava, processTestResources, buildImage
    }
    
    dockerCompose {
        // see the logs of all services in build/docker-compose.log for debugging.
        captureContainersOutputToFile = 'build/docker-compose.log' 
    }
    
    dockerCompose.isRequiredBy(integrationTest)
    
    check.dependsOn test, integrationTest


### usage inside tests

The gradle plugin fills java's system properties with the needed value to access the dependent services:

Inside the test: Get the mapped port using the name of the service and it's internal port number

    String port = System.getProperty("mysql.tcp.3306");

### local development 
Sometimes I want to start the environment and leave it running and then I want to run one single test independently.

There are two ways to achieve this:

#### a) Use docker-compose.override.yml

1. Put a `docker-compose.override.yml` next to the docker-compose file.
2. Override the ports:

        version: '3'
        
        services:
          mysql:
            ports:
              - '3306:3306'

3. add the `docker-compose.override.yml` to `.gitignore` so that you do not mess any other developer's settings.
5. provide the port from the docker-compose.override.yml as a default, wenn accessing the dependent service:

        int port = Integer.parseInt(System.getProperty("mysql.tcp.3306": "3306");


#### b) use docker inspect


        public class DockerInspect {
        
            DockerClient docker;
        
            public DockerInspect() {
                this.docker = DockerClientBuilder.getInstance().build();
            }
        
            public GetPorts getHostPort(String containerName) {
                InspectContainerResponse response = docker.inspectContainerCmd(containerName).exec();
                Map<ExposedPort, Ports.Binding[]> bindings = response.getNetworkSettings().getPorts().getBindings();
                return exposedPort -> {
                    Ports.Binding[] portBindings = bindings.get(exposedPort);
                    return asList(portBindings).stream().map(binding -> parseInt(binding.getHostPortSpec())).collect(Collectors.toList());
                };
            }
        
            public interface GetPorts {
                List<Integer> getPortOnHost(ExposedPort exposedPort);
            }
        }


Inside the test

        List<Integer> mysqlPorts = new DockerInspect().getHostPort("mysql").getPortOnHost(new ExposedPort(3306, InternetProtocol.TCP));


## Comparison docker-compose testcontainers vs docker-compose gradle plugin

### Testcontainers
- Suitable when you have the view "I need a container in this test".
- Advantage: Perfectly cleans up the started containers after usage due to the [Ryuk Container&#8599;](https://github.com/testcontainers/moby-ryuk).
- Does some network voodoo that might interfere with your test setup.

### gradle plugin
- suitable when you have the view "I need a container in this test suite"
- Advantage: see logs of all services in build/docker-compose.log for debugging
- Advantage: Faster turnaround cycles when developing locally because the containers can be left running.
- Disadvantage: If your build job is interrupted/killed, there are sometimes some running containers left on the host. You need to setup a job on your ci server to kill them, e.g. in the night. 


*Any comments or suggestions? Leave an issue or a pull request!*