---
layout: post
title:  "Top 7 Tools for Testing in Java"
date:   2020-06-16 16:00:00 +0200
categories: [software, testing]
tags: [java, mockito, unit test, easyrandom, testcontainers, wiremock, testng]
---

*Disclaimer: This post is highly opinionated!*

Here are my top favourite tools for testing in java:

# Mockito

[Mockito](https://site.mockito.org/) seems to be the de-facto standard for creating mock objects in java and is imho far better than [easymock](https://easymock.org/).

Some hints:

* I prefer using the BDD mockito style. I like to structure my tests in given-when-then blocks. When I write `when(mock.method()).thenReturn(value)` I always get confused in my head because I'm still in the "given" block. So I prefer the `given(mock.method()).willReturn(value)` style more.
* I like to [populate an object under test with only one line of code](/software/testing/2014/01/14/MockInjector.html).

# Selenium / WebDriver

[Selenium](https://www.selenium.dev/documentation/en/) is the de-facto standard for testing web applications.

# Testcontainers

Need a database for your tests? Need a browser for your selenium tests? Use [testcontainers](https://www.testcontainers.org/) and easily set up everything without headache.

Some hints for its usage can be found on [one of my former blog posts](/software/testing/2020/03/29/testcontainers.html).

# WireMock

You need to fake some remote http service? Here comes [wiremock](http://wiremock.org/docs/getting-started/)!

# AssertJ

I already liked to work with fest assertions. Now my favourite is [AssertJ](https://assertj.github.io/doc/). 

* fluent API 
* API is close to natural language
* API is easy to autocomplete in your IDE
* You do not always confuse "actual" and "expected" values.

# EasyRandom

You have some value object, that should be used in a test, but its values are not important?
Use [EasyRandom](https://github.com/j-easy/easy-random) to populate it with some random values.

# TestNG

Working with [JUnit 5](https://junit.org/junit5/) is ok, but [TestNG](https://testng.org/doc/index.html) is far more better.

TestNG has good parameterized tests ("DataProvider") since more than ten years. TestNG's concept of suites is far more mature than JUnit's tags.
In JUnit I sometimes need to write static initializers for some test setup. TestNG is far more flexible here. 

[More about Testing](/collections/testautomation.html)

*Any comments or suggestions? Leave an issue or a pull request!*