---
layout: post
title:  "Three ways to find a free tcp port on your Jenkins server"
date:   2020-03-20 10:03:00 +0100
categories: [software, testing]
tags: [software, ci, free port, port, jenkins]
---

![Port](/assets/port.jpg)

<small>Image by [Hamuraj&#8599;](https://pixabay.com/de/users/Hamuraj-364370/?utm_source=link-attribution) from [Pixabay&#8599;](https://pixabay.com/?utm_source=link-attribution)</small>

When testing web applications on your [Jenkins&#8599;](https://jenkins.io/) server you will soonly find yourself opening your web application on a [port&#8599;](https://en.wikipedia.org/wiki/Port_(computer_networking)) for some integration tests for your [REST API&#8599;](https://en.wikipedia.org/wiki/Representational_state_transfer) or for a [selenium test&#8599;](https://www.selenium.dev/).

**But which port should you choose?**

If you just start your application on a standard port (e.g. 8080) you will soonly have conflicts with your collegues running their CI jobs.
You could use the [port allocator plugin&#8599;](https://plugins.jenkins.io/port-allocator/) to handle that.

But maybe you are lucky and your application under test can run on any tcp port.
Then you could find a (random) free port to open your web application.

In this post I will share three ways of finding a free tcp port.

## 1. Find a free random port in your Jenkinsfile

Your [Jenkinsfile&#8599;](https://jenkins.io/doc/book/pipeline/jenkinsfile/) is written in a [groovy language&#8599;](http://www.groovy-lang.org/)based [DSL&#8599;](https://en.wikipedia.org/wiki/Domain-specific_language). It can basically execute any groovy code. 
Since 99% of Java code is groovy compatible (older versions of groovy can not understand java's inline array initializers and new language features of Java8 such as lambdas),
you can also write Java code inside your Jenkinsfile.
So you can allocate a free port just using:

````
int localServerPort = null
ServerSocket serverSocket;
try {
  serverSocket = new ServerSocket(0)
  localServerPort = serverSocket.getLocalPort()
  echo("using port: " + localServerPort)
  serverSocket.close()
} catch (IOException ex) {
  echo("could not find a free port ${ex.message}")
}
finally {
  if (serverSocket != null) {
    try {
      serverSocket.close()
    } catch (IOException ignore) {
    }
  }
}
````
**Disadvantage**

If you have found a free port at the beginning of the build and try to bind the port later, there is a chance that maybe an other job has allocated the same port meanwhile.

### Update: 

In a scripted pipeline you can put this code almost anywhere.
In a declared pipeline you can add a function at the very end after the closing pipeline block.
Example:

```
pipeline {
    ...
    stage("build") {
        environment {
            SERVER_PORT = findFreePort()
        }
        steps {
            sh "./gradlew build -DserverPort=${env.SERVER_PORT}"
        }
    }
    ...
}

int findFreePort() {
    ServerSocket serverSocket
    try {
        serverSocket = new ServerSocket(0)
        int localServerPort = serverSocket.getLocalPort()
        echo("using port: " + localServerPort)
        serverSocket.close()
        return localServerPort
    } catch (IOException ex) {
        echo("could not find a free port ${ex.message}")
        throw ex;
    }
    finally {
        if (serverSocket != null) {
            try {
                serverSocket.close()
            } catch (IOException ignore) {
            }
        }
    }
}

```

## 2. Build inside a docker container

Building inside a [docker&#8599;](https://www.docker.com/) container has many advantages:
- No conflicts with shared preinstalled software (Maven/Java/Python... versions)
- use any tools you like without need to first ask your CI-Server administrators
- virtual network of your container

So if your build runs inside a docker container you can bind any port of your container, without interfering any other build.
You can even use fixed ports.

**Disadvantages:**

* If your build includes handling with docker containers, you might soonly find yourself in a [docker-in-docker](https://jpetazzo.github.io/2015/09/03/do-not-use-docker-in-docker-for-ci/) situation.
 
* Writing your selenium tests to access "localhost" might not be trivial anymore.


## 3. Port allocation by convention of number ranges

If you look at [wikipedia's list of standard tcp ports&#8599;](https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers), you may find that there are not many ports used above 35000.
Especially in the areas of 35xxx, 36xxx, 39xxx, 42xxx, 45xxx, 47xxx, 48xxx there is much free space.

You just need to make sure that there is no other build job using your port. You can avoid that by declaring number ranges:
On your build agent server there are many executors. You can access the executor number by an environment variable in your Jenkinsfile `EXECUTOR_NUMBER`

So let's assume we want to use the ports between 39000 and 39999 and every Jenkins build server does not have more than 9 executors to run jobs in parallel:

We declare that every executor should be able use up to 100 ports inside it's range.
Then you could start your build job in your Jenkinsfile like:

    "yourbuildcommand -port0 39${env.EXECUTOR_NUMBER}80 -port1 39${env.EXECUTOR_NUMBER}81 -port3 39${env.EXECUTOR_NUMBER}25"

if you build job needs three ports to allocate.

**Disadvantage**

* You should make people agree the the rule of using range number for ports. If not, you might still have port conflicts.

* If the service once can't free the port on stopping, that port remains blocked until manual interaction, e.g. reboot of the Jenkins node.

*Any comments or suggestions? Leave an issue or a pull request!*
