---
layout: post
title:  "Parallel Builds with Jenkins and gradle"
date:   2020-11-20 10:03:00 +0100
categories: [software, testing]
tags: [software, ci, jenkins, gradle, parallel]
---

[JUnit 5&#8599;](https://junit.org/junit5/) and [TestNG&#8599;](https://testng.org/doc/index.html) have good support for parallelizing tests. 
And usually you should stick to that and not do anything else.
But sometimes you have some reasons why you cannot use that.
In my case, the legacy software had tests that did some system wide stubbing which was a show stopper for parallel tests.

When the tests took too much time, we thought that we should run them in parallel. 
Because of the bad tests, we had to start different java processes.

First of all, you should use JUnit Tags or TestNG groups to group your tests into different suites that can run independently.
Then you structure your build, that you first compile the classes and then run the test suites in parallel:

![parallel build](/assets/parallel-build.png)


build.gradle:
```groovy
    test {
        useJUnitPlatform {
            includeTags 'suite1'
            excludeTags 'suite2'
        }
    }
    
    task testSuite2(type: Test) {
        useJUnitPlatform {
            includeTags 'suite2'
            excludeTags 'suite1'
        }
        dependsOn compileTestJava, processTestResources
    }

    check.dependsOn testSuite2
```

Then you setup [parallel execution in your Jenkinsfile&#8599;](https://www.jenkins.io/blog/2017/09/25/declarative-1/):
```groovy
pipeline {
    stages {
        stage("compile") {
            steps {
                sh "./gradlew build -x test -x testSuite2"        
            }
        }
        stage ("test"){
            parallel {
                stage("testSuite1") {
                    steps {
                        sh "./gradlew test"        
                    }
                }  
                stage("testSuite1") {
                    steps {
                        sh "./gradlew testSuite2"        
                    }
                }
            }
        }
    }
}
```
If you run this, you will find that the steps "testSuite1" and "testSuite2" will compile the classes, too.

How to copy the compiled classes from step compile to the test steps?

I can combine [gradle's build cache&#8599;](https://docs.gradle.org/current/userguide/build_cache.html) and [Jenkins' stash feature&#8599;](https://www.jenkins.io/doc/pipeline/steps/workflow-basic-steps/#stash-stash-some-files-to-be-used-later-in-the-build). But attention: I can not unstash the same stash twice, so I have to copy directories into different stashes: 

settings.gradle:
```groovy
buildCache {
    local(DirectoryBuildCache) {
        directory = new File(rootDir, 'build-cache')
        removeUnusedEntriesAfterDays = 1
    }
}
```

Jenkinsfile:

```groovy
pipeline {
    stages {
        stage("compile") {
            steps {
                // clean
                sh "if [ -d build-cache ]; then rm -r build-cache; fi"
                // build
                sh "./gradlew --build-cache clean build -x test -x testSuite1"
                // stash 1
                sh "mkdir build/stash1"
                sh "cp -r build-cache build/stash1"
                stash includes: 'build/stash1/**', name: 'stash1'
                // stash 2
                sh "mkdir build/stash2"
                sh "cp -r build-cache build/stash2"
                stash includes: 'build/stash2/**', name: 'stash2'
            }
        }
        stage ("test"){
            parallel {
                stage("testSuite1") {
                    steps {
                        // clean
                        sh "if [ -d build-cache ]; then rm -r build-cache; fi"
                        sh "./gradlew clean"
                        // unstash                        
                        unstash 'stash1'
                        sh "mv build/stash1/build-cache ."
                        sh "rm -Rf build/stash1"
                        // test            
                        sh "./gradlew --build-cache test"        
                    }
                }  
                stage("testSuite2") {
                    steps {
                        // clean
                        sh "if [ -d build-cache ]; then rm -r build-cache; fi"
                        sh "./gradlew clean"
                        // unstash
                        unstash 'stash2'
                        sh "mv build/stash2/build-cache ."
                        sh "rm -Rf build/stash2"
                        // test
                        sh "./gradlew --build-cache testSuite2"        
                    }
                }
            }
        }
    }
}
```


*Any comments or suggestions? Leave an issue or a pull request!*
