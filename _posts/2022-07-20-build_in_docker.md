---
layout: post
title:  "Build fails in CI but succeeds locally?"
date:   2022-07-20 18:00:00 +0200
categories: [software, testing]
tags: [software, testing, ci, jenkins]
---

Sometimes it happens that your build is successful locally, but it fails on CI.

What can you do? The simplest, but most time-consuming thing: Add logging in order to find out.

But what if you could run the build on your local machine, just like it is done in your build server?

If you do your builds on your build server inside a docker container, then you can create a environment on your local machine that is closer to the build server's environment:

```bash
#!/usr/bin/env bash

docker run \
    -t \            # print output into terminal, if you do not add this switch, you will need to jump to docker logs
    -it \           # interactive: you can stop the build by pressing CTRL-C 
    --volume=$(pwd):$(pwd):rw,z -w $(pwd) \  # map your local directory into the docker container
    -u 1000:1000 \                           # run the build using your local user. If not, you will need to 'sudo' for deleting the build target directory
    gradle:jdk17-alpine \                    # or any other docker image you use for building
     /bin/sh -c "./gradlew build --info --stacktrace"   # or any other command you use for building, like 'mvn verify'

```

If that does not work or if you use testcontainers, then there might be some more options to help you:

```bash
#!/usr/bin/env bash

docker run -it -t -u 1000:1000 \
    --volume=$(pwd):$(pwd):rw,z -w $(pwd) \
    --volume=/var/run/docker.sock:/var/run/docker.sock \  # add map the docker socket as a volume into your docker container
    --volume=${HOME}/.docker:/home/jenkins/.docker \      # add map the .docker directory into the the build user's home directory: In this case, the user name was "jenkins". This is necessary, if the build cannot pull images from a docker repository, that needs credentials.
    --group-add 999 \   # might help with some access problems
    --privileged \      # might help with some privilege problems
    --net=host \        # should usually not be used, but sometimes it can help if you have routing problems, e.g. because of working in a VPN
    gradle:jdk17-alpine /bin/sh -c "./gradlew build --info --stacktrace"

```

If your build fails locally in the same way as it fails on production, then you now have a way to easier debug things locally:
* Maybe the docker image used in the build does not support features you have in your local environment.
* For shorter turnaround cycles: Do not run all the tests, but only the test that fails.
* In some special cases you could even add and open a debug port and do remote debugging using your IDE.

If your build succeeds locally, then maybe the issue is on the server:
* Maybe you will need to add more CPU/RAM to the build's docker container.
* Maybe there are still some old docker containers hanging on the build host: Stop them.

Generally: On every build host you should add a cron job that does `docker stop $(docker ps -a -q)` to stop all running docker containers at some time in the middle of the night, especially if you use [localstack and lambdas](https://joerg-pfruender.github.io/software/testing/2020/09/27/localstack_and_lambda.html) or [docker compose gradle plugin](https://joerg-pfruender.github.io/software/testing/2020/04/18/docker-compose-gradle.html)

*Any comments or suggestions? Leave an issue or a pull request!*
