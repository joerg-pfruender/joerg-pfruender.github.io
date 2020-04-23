---
layout: post
title:  "gradle and docker-compose"
date:   2020-04-18 16:40:00 +0200
categories: [software, testing]
tags: [software, java, docker-compose, gradle]
---

Some weeks ago I have posted some thoughts on [Testcontainers](https://joerg-pfruender.github.io/software/testing/2020/03/29/testcontainers.html).
When dealing with [docker-compose&#8599;](https://docs.docker.com/compose/) there is a way, that I prefer over using testcontainers.

## divide tests in unit tests and integration tests

Personally I like the [maven&#8599;](http://maven.apache.org/) style of testing (although there are some other things in maven that I really hate).
It divides testing into several [phases&#8599;](https://maven.apache.org/ref/3.6.3/maven-core/lifecycles.html), that really make sense:
  
* unit-tests: perform all tests that are easy to run because they have mocked dependencies.
* pre-integration-test: setup a test fixture for the integration tests
* integration-test: perform all the integration tests
* post-integration-test: teardown the test fixture

I like to do testing like this with [gradle&#8599;](https://gradle.org/) as well and [Petri Kainulainen explains how to do it&#8599;](https://www.petrikainulainen.net/programming/gradle/getting-started-with-gradle-integration-testing/).

## docker-compose gradle plugin

And for this scenario, I prefer [Avast's docker-compose gradle plugin&#8599;](https://github.com/avast/gradle-docker-compose-plugin).

### build configuration

example docker-compose.yml

    version: '3'
    
    services:
      mysql:
        image: mysql:8.0.16
        ports:
          - '3306'


example build.gradle (extract)

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

Inside the test you can obtain the mapped port using the name of the service and it's internal port number:

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

### docker-compose testcontainers
- Suitable when you have the view "I need a container in this test".
- Advantage: Perfectly cleans up the started containers after usage due to the [Ryuk Container&#8599;](https://github.com/testcontainers/moby-ryuk).

### docker-compose gradle plugin
- suitable when you have the view "I need a container in this test suite"
- Advantage: see logs of all services in build/docker-compose.log for debugging with just one line of configuration.
- Disadvantage: If your build job is interrupted/killed, there are sometimes some running containers left on the host. You need to setup a job on your ci server to kill them, e.g. in the night. 

*Any comments or suggestions? Leave an issue or a pull request!*

[Sergei Egorov&#8599;](https://twitter.com/bsideup) has written:

> \> Does some network voodoo that might interfere with your test setup.
> 
> What voodoo?
> 
> \> see logs of all services in build/docker-compose.log for debugging
>
> Can be done with TC
>
> \> Faster turnaround cycles
>
> Reusable containers in TC
 
via [Twitter&#8599;](https://twitter.com/bsideup/status/1251803587128307712)

*Thank you for your comments. I have updated the comparison section*
* *Network: I have removed "Does some network voodoo that might interfere with your test setup." I can not reproduce the issue anymore*
* *Logs: I know that you can capture all logs with testcontainers, too. More information about that can be found on [https://www.testcontainers.org/features/container_logs/ &#8599;](https://www.testcontainers.org/features/container_logs/). With the gradle-plugin it's just dead simple with one line of configuration. I've changed it from "see logs of all services in build/docker-compose.log for debugging" to "see logs of all services in build/docker-compose.log for debugging with just one line of configuration." to make it more clear.*
* *Reusable: I haven't seen Reusable Containers in Testcontainers before. Thank you for the link to [your blog post about that&#8599;](https://bsideup.github.io/posts/local_development_with_testcontainers/). I've removed "Advantage: Faster turnaround cycles when developing locally because the containers can be left running." from gradle-plugin advantages*

   
