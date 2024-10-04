---
layout: post
title:  "Test your logging!"
date:   2024-01-02 14:00:00 +0100
categories: [software, testing]
tags: [software, testing, unit tests, logging, mocks, mockito]
---

![large_zippers](/assets/zippers.jpg)

<small>&copy; Image by [Margarethe Pfründer-Sonn&#8599;](http://www.pfruender-sonn.de/objekte/reissverschluesse-veraenderbare-wandbehaenge)</small>

Let's look at this piece of code:

```java

  void processData(data){
    if(isValid(data)){
      delegate.doProcess(data);
    }
    else{
      logger.error("cannot process " + data.id + " because it is invalid");
    }
  }
```
Then, we add some checks to the logging system that alerts when the error log occurs.

You probably have something similar in your services.

When an error occurs, we want to find log statements. If the logging and alerting fails, we will have silent errors. Silent errors are almost impossible to find.
We heavily depend on log messages in order to ensure that the system is working properly.

Now imagine this: The method "isValid" is throwing an exception instead of returning `false`. This is a little mistake. Little mistakes can happen. Maybe the caller of this peace of code will log the exception, but we cannot be sure. I have often seen toplevel entrypoints without proper logging.
In this case we have a silent failure. Our monitoring will not catch anything.

We aim for 100% unit test coverage.
It is easy to write a test that executes the `else` part of the block. But usually the log is initialized like this:

```java

  private static final Logger logger = LoggerFactory.getLogger(ClassName.class);

```

That has two disadvantage:
##### 1. It pollutes the build log
When executing unit tests, the error message will occur in the build log. 
Imagine you are hunting a failing test, and you look inside the build log to spot an exception.
But there are all those error log statements in your build log, and now it takes ages to find the reason for the failing tests. 

##### 2. You cannot properly mock the logger 

I'd like to have a test like this:

```java

  @Test
  void invalidDataWillLogError() {
     // given
     underTest.logger = mock(Logger.class);
     val invalidData = createInvalidData();
     
     // when
     underTest.processData(invalidData);
     
     // then
     verify(underTest.logger).error(startsWith("cannot process"));
  }

```

This is not possible with a "private final static" logger.

How could we solve this? We could mitigate our problem with a special logging configuration for unit tests.
Then the errors would not appear in the build logs. With some effort we could even create some test to ensure that log statements are there.
But still this test would not be thread-safe. If we want to parallelize our tests (for saving build time) then we will run into trouble.

Why did we start using "private final static" in the first place?
1. `private final` is some sort of information hiding; it prevents other code from messing with the logger field.
2. `static` removes the overhead from initializing the logger every time a new instance of the class is created.

Most of the classes with business logic will be singletons at runtime, because this is the default scope in the spring framework. For singletons, the `static` logger initialization has no advantage.
IMHO, it is safe enough to have "package local" scope, no need for `private final`.

So, my proposal for logger initialization (for runtime singletons) is:

```java
  Logger logger = LoggerFactory.getLogger(ClassName.class);
```

I value a good unit test over information hiding.

#### External Link:
* [slf4j FAQ](https://www.slf4j.org/faq.html#declared_static)

[More about Testing](/collections/testautomation.html)

*Any comments or suggestions? Leave an issue or a pull request!*