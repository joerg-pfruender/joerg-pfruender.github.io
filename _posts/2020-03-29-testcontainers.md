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

## Database-Containers

One of the most impressive and easy to use things are [database testcontainers&#8599;](https://www.testcontainers.org/modules/databases/):
You do not need to use in memory databases like hsqldb or h2 for your tests, but you can use the same database engine which runs production.
You can choose among a large list of many popular database images.

It's so easy that I have only one advice for you:
Try to minimize the numbers of container startups. 
If you have multiple tests, that need a database, then do not startup and shutdown the container for each test. Your test times will explode.
Better use the same container and clean up your database after your test or create a database with a random name for each test on the samce container instance.

If you want to startup a shared database container for all tests you have at least two options.

* If you use [TestNG&#8599;](https://testng.org/doc/) you can spin up the container in the `@BeforeSuite` phase of your test suite and stop it in `@AfterSuite`.
* If you are not lucky to use TestNG you can use a [singleton container&#8599;](https://www.testcontainers.org/test_framework_integration/manual_lifecycle_control/#singleton-containers) .
 The awesome thing is: You do not need to care for stopping the container. The [Ryuk Container&#8599;](https://github.com/testcontainers/moby-ryuk) will care about that for you!

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

Putting it all together:

    Testcontainers.exposeHostPorts(port);
    WebDriver webDriver = new BrowserWebDriverContainer()
            .withCapabilities(new ChromeOptions())
            .withRecordingMode(VncRecordingMode.RECORD_FAILING, new File("./target/"));
    webDriver.get("http://host.testcontainers.internal:" + port + "/");



### Get videos of failing tests with JUnit5

The main problem: currently testcontainers is not informed by Junit5 that the test has failed.
We can implement that on our own, but it is not easy to find the container for the test.

The basic idea:


        public class ScreenshotOnFailedTestExtension implements AfterEachCallback {
        
            @Override
            public void afterEach(ExtensionContext extensionContext) {
                if (extensionContext.getExecutionException().isPresent()) {
                    // here: notify testcontainers that the test has failed....
                    BrowserWebDriverContainer container = findContainerInstance(); // TODO: this will be fun for you to implement
                    container.afterTest(new TestDescription() {
                            @Override
                            public String getTestId() {
                                return "testId"; // TODO
                            }
        
                            @Override
                            public String getFilesystemFriendlyName() {
                                return "name"; // TODO
                            }
                        }, executionException);
        
                }
            }
        }

I do this with a workaround:
Each of my tests uses the ScreenshotOnFailedTestExtension and implements the HasWebdriver interface. By using this interface I can inform the webdriver to save the video
The Webdriver, you mean the container!
Well, I use my own implmentation of a webdriver, that holds the container and delegates every webdriver call to the "real" webdriver.

**The complete code can be found in my [github repository&#8599;](https://github.com/joerg-pfruender/webdriver-testcontainers-junit5).**

It has only one disadvantage: Starting and stopping a new container too often is slower than using a local webdriver.


        @ExtendWith({RecordVideoOnFailedTestExtension.class})
        class SampleTest implements HasWebDriver {
        
        
            WebDriver webDriver;
        
            @Test
            void sampleTest() throws Exception {
        
                Testcontainers.exposeHostPorts(port);
                BrowserWebDriverContainer container = new BrowserWebDriverContainer()
                        .withCapabilities(new ChromeOptions())
                        .withRecordingMode(BrowserWebDriverContainer.VncRecordingMode.RECORD_FAILING, new File("./build/"));
                webDriver = VideoRecordingWebDriver.create(container);
                webDriver.manage().timeouts().implicitlyWait(10, TimeUnit.SECONDS);
                webDriver.get("http://host.testcontainers.internal:" + port + "/");
        
            }
        
            @Override
            WebDriver getWebDriver() {
                return webDriver;
            }
        }

## Think before use docker-compose containers...

Not long time ago testcontainers' [docker-compose module&#8599;](https://www.testcontainers.org/modules/docker_compose/) only supported `docker-compose.yml`s up to version 2. The only workaround was using the native docker-compose command which meant you needed to install docker-compose on every machine. That was really annoying. 
But things have changed: The newest code makes the version of the docker-compose container configurable.

### Containers can't call outside

If you want to use testcontainers' docker-compose to start some of your self-made docker images to startup a container, then you might find that they can not call outside.
Maybe things have changed meanwhile, but in my experiments the reason was the [ambassador container&#8599;](https://github.com/testcontainers/testcontainers-java/blob/master/core/src/main/java/org/testcontainers/containers/AmbassadorContainer.java), that does some network voodoo. 
Docker itself does some tricks to your firewall, that enables your containers to call the outside world, but the ambassador container bypasses that.
My container inside testcontainers docker-compose was only able to call outside when I teared down the firewall. Of course I did not want to do that.

Currently I prefer using  [com.avast.gradle:gradle-docker-compose-plugin&#8599;](https://github.com/avast/gradle-docker-compose-plugin) which still has it's own problems but that will be part of an other blog post.

*Any comments or suggestions? Leave an issue or a pull request!*