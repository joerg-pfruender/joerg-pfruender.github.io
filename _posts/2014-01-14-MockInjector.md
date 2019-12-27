---
layout: post
title:  "Create Mocks without writing code"
date:   2014-01-14 23:59:59 +0100
categories: [software, testing]
tags: [java, mockito, unit test]
---

    @BeforeMethod 
    public void setUp() { 
        objectUnderTest = MockInjector.injectMocks(MyClass.class); 
    } 

I have been bored to write so much boilerplate code for mocks in unit tests.
That's why some collegues from my former company and I, we have written a [nice little tool&#8599;](https://github.com/hypoport/MockInjector) to do the boilerplate code. 

I have written a blog post at my former companys blog on its usage:

**[Use MockInjector and package protected scope for dependencies to reduce boilerplate code&#8599;](https://tech.europace.de/use-mockinjector-and-package-protected-scope-for-dependencies-to-reduce-boilerplate-code/)**



*Any comments or suggestions? Leave an issue or a pull request!*