---
layout: post
title:  "Testcontainers in practice"
date:   2020-03-29 22:50:00 +0200
categories: [software, testing]
tags: [software, java, testcontainers, webdriver, selenium]
---

Since some months, the [testcontainers&#8599;](https://www.testcontainers.org/) project is dramatically increasing the productivity of software tests in java.
The api is simple and straightforward, easy to understand: You can start using containers for your tests after just 5 minutes documentation reading. It's really awesome.

Having used testcontainers for some months, I want to share some of my experiences:

## Database Containers

One of the most impressive and easy to use things are [database testcontainers&#8599;](https://www.testcontainers.org/modules/databases/):
You do not need to use in memory databases like hsqldb or h2 for your tests, but you can use the same database engine which runs production.
You can choose among a large list of many popular database images.

It's so easy that I have only one advice for you:

**Try to minimize the numbers of container startups!**

If you have multiple tests, that need a database, then do not startup and shutdown the container for each test. Your test times will explode.
Better use the same container and clean up your database after your test or create a database with a random name for each test on the samce container instance.

If you want to startup a shared database container for all tests you have at least two options.

* If you use [TestNG&#8599;](https://testng.org/doc/) you can spin up the container in the `@BeforeSuite` phase of your test suite and stop it in `@AfterSuite`.
* If you are not lucky to use TestNG you can use a [singleton container&#8599;](https://www.testcontainers.org/test_framework_integration/manual_lifecycle_control/#singleton-containers) .
 The awesome thing is: You do not need to care for stopping the container. The [Ryuk Container&#8599;](https://github.com/testcontainers/moby-ryuk) will care about that for you!

In order to speed up test execution: 
**Use a in-memory volume** for the directory, where the database stores the data.

Example for [MySQLContainer&#8599;](https://www.testcontainers.org/modules/databases/mysql/):

    container = new MySQLContainer("mysql:5.5")
                .withTmpFs(Map.of("/var/lib/mysql", "rw"))  

Example for docker-compose:

    services:
      mysql:
        image: mysql:8.0.16
        ports:
          - '3306'
        tmpfs:
          - /var/lib/mysql

## Selenium / Webdriver

I have had several hard times with [selenium&#8599;](https://www.selenium.dev/) tests when the browser vendors released new versions of their browsers. All selenium tests have broken (or were instable) and I had much work with fixing stuff.
Not any more with testcontainers. You can run the same tests with the same browser on every system and you do not need to care if other developer's workstations run Windows, Mac OS or Linux.

If you are new, then I have two tricks for you:

### Where is "localhost"?

Usually you run your webdriver and your server on the same host, so you can simply use "localhost" to access your server. 
But if your webdriver runs inside a testcontainer then your webdriver will not find any server on "localhost".
What to do?
1. You need to expose the server's port to the testcontainers:
   [`Testcontainers.exposeHostPorts(localServerPort);`&#8599;](https://www.testcontainers.org/features/networking/)
   
   You should do that before starting the webdriver container.

2. Find "localhost": 
   Your "localhost" will be `"host.testcontainers.internal"`


### Get videos of failing tests with JUnit5

**Update 2020-04-23**

Testcontainers has released Version 1.14.1 which supports videos from Testcontainers with [JUnit5&#8599;](https://junit.org/junit5/).

One thing is important: 

Your BrowserWebdriverContainer must be a field in the test, annotated with @Container to work with videos.

You should not start/stop the container in *your* code. That is done by hooks initialized by the @Testcontainers annotation.
It scans for fields annotated with @Container and executes their start/stop methods.
If you do not put your BrowserWebdriverContainer into a @Container annotated field and start/stop it on your own, 
then the framework can not inform the container if the test has failed and there will be no video on failing tests. 

### Putting it all together:


    @Testcontainers
    public class SampleTest {
    
        @Container
        BrowserWebDriverContainer container = new BrowserWebDriverContainer()
                .withCapabilities(new ChromeOptions())
                .withRecordingMode(BrowserWebDriverContainer.VncRecordingMode.RECORD_FAILING, new File("./build/"));
                    
        @BeforeAll
        public static void setUp() {
            org.testcontainers.Testcontainers.exposeHostPorts(port);
    
        }
                    
        @Test
        void testA() {     
            WebDriver webDriver = container.getWebDriver();       
            webDriver.get("http://host.testcontainers.internal:" + port + "/");
        }
        
    }    

The complete code can be found in [https://github.com/joerg-pfruender/webdriver-testcontainers-junit5 &#8599;](https://github.com/joerg-pfruender/webdriver-testcontainers-junit5)

## docker-compose containers

Not long time ago testcontainers' [docker-compose module&#8599;](https://www.testcontainers.org/modules/docker_compose/) only supported `docker-compose.yml`s up to version 2. The only workaround was using the native docker-compose command which meant you needed to install docker-compose on every machine. That was really annoying. 
But things have changed: The newest code makes the version of the docker-compose container configurable.

### more...
about testcontainers: [Three obstacles when testing lambdas with testcontainers and localstack](/software/testing/2020/09/27/localstack_and_lambda.html)

*Any comments or suggestions? Leave an issue or a pull request!*

**Update 2022-09-03**
In-Memory volume for database

**Update 2020-04-23**
* removed own implementation of getting videos and updated documentation to Testcontainers version 1.14.1
* removed network issues from docker-compose because not reproducable, added link to other blog post.