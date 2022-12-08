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

I have written a blog post at my former company's blog on its usage:

**[Use MockInjector and package protected scope for dependencies to reduce boilerplate code&#8599;](https://tech.europace.de/use-mockinjector-and-package-protected-scope-for-dependencies-to-reduce-boilerplate-code/)**


# Update 2022-12-08

I have forked the project, because nobody at Hypoport had answered to my pull requests.

It is now available via [https://github.com/joerg-pfruender/MockInjector](https://github.com/joerg-pfruender/MockInjector)

### maven
```xml
    <dependency>
      <groupId>io.github.joerg-pfruender</groupId>
      <artifactId>mockito-mockinjector</artifactId>
      <version>3.0</version>
      <scope>test</scope>
    </dependency>
``` 
### gradle

```groovy
    testImplementation 'io.github.joerg-pfruender:mockito-mockinjector:3.0'
```

I've also updated the Intellj IDEA templates:

### JUnit 5 template

```
        #parse("File Header.java")
        #if (${PACKAGE_NAME} != "")package ${PACKAGE_NAME};#end
        
        #if ($NAME.endsWith("Test"))
        import org.junit.jupiter.api.BeforeEach;
        import org.junit.jupiter.api.Test;
        import static org.pfruender.mockinjector.MockInjector.injectMocks;
        #end
        
        #parse("Type Header.java")
        class ${NAME} {
        
        #if ($NAME.endsWith("Test"))
        
          $NAME.replace("Test", "") $NAME.substring(0, 1).toLowerCase()$NAME.replace("Test", "").substring(1);
        
          @BeforeEach
          void setUp() throws Exception {
            $NAME.substring(0, 1).toLowerCase()$NAME.replace("Test", "").substring(1) = injectMocks($NAME.replace("Test", "") .class);
          }
        
        #end
        }


```

### TestNG template

```
        #parse("File Header.java")
        #if (${PACKAGE_NAME} != "")package ${PACKAGE_NAME};#end
        
        #if ($NAME.endsWith("Test"))
        import org.testng.annotations.BeforeMethod;
        import org.testng.annotations.Test;
        
        import static org.pfruender.mockinjector.MockInjector.injectMocks;
        #end
        
        #parse("Type Header.java")
        public class ${NAME} {
        
        #if ($NAME.endsWith("Test"))
        
          $NAME.replace("Test", "") $NAME.substring(0, 1).toLowerCase()$NAME.replace("Test", "").substring(1);
        
          @BeforeMethod
          public void setUp() throws Exception {
            $NAME.substring(0, 1).toLowerCase()$NAME.replace("Test", "").substring(1) = injectMocks($NAME.replace("Test", "") .class);
          }
        
        #end
        }
```

*Any comments or suggestions? Leave an issue or a pull request!*