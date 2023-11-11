---
layout: post
title:  "Spring Cloud and BigQuery and Testcontainers"
date:   2023-11-01 21:10:00 +0100
categories: [software, testing]
tags: [software, testing, spring, spring-boot, spring-cloud, bigquery, testcontainers]
---

[Spring boot](https://spring.io/projects/spring-boot) is the most popular java framework for web applications.

[Testcontainers](https://java.testcontainers.org/) is the most popular technology for mocking external dependencies during automated tests.

[BigQuery](https://cloud.google.com/bigquery/) is Google's cloud data warehouse.

It should be easy to test those in combination.

It's not!

Let's start with [spring's sample project for BigQuery](https://github.com/GoogleCloudPlatform/spring-cloud-gcp/tree/main/spring-cloud-gcp-samples/spring-cloud-gcp-bigquery-sample). We change the existing test, so that it uses Testcontainers' BigQuery mock instead of the the real BigQuery implementation from Google.

## Problem #1 Override endpoint

There's no obvious configuration to override the BigQuery endpoint.

Spring boot's default connection endpoint is a Google URL, which totally makes sense in production.

But there is no built-in option for overriding the endpoint. We need to do this on our own. 

Pay attention: `com.google.api.gax.rpc.ClientSettings.Builder#setEndpoint` does not like to have the full URL, but just the host and port:

```java
  @Bean
  @Primary
  public BigQuery bigQuery() {
    String url = "http://" + httpHostAndPort;
    BigQueryOptions options = BigQueryOptions
            .newBuilder()
            .setProjectId(projectId)
            .setHost(url)
            .setLocation(url)
            .setCredentials(NoCredentials.getInstance())
            .build();
    return options.getService();
  }

  @Bean
  @Primary
  public BigQueryWriteClient bigQueryWriteClient() throws IOException {
    return BigQueryWriteClient.create(BigQueryWriteSettings.newBuilder()
            .setCredentialsProvider(new NoCredentialsProvider())
            .setEndpoint(httpHostAndPort)
            .setQuotaProjectId(projectId)
            .setHeaderProvider(new UserAgentHeaderProvider(GcpBigQueryAutoConfiguration.class))
            .build());
  }
```

## Problem #2 No Credentials

Overriding the BigQuery endpoint, does not override the endpoints for Google's token management. So you might see one of those exceptions:
```
com.google.api.gax.rpc.UnauthenticatedException: io.grpc.StatusRuntimeException: UNAUTHENTICATED: Failed computing credential metadata

java.io.IOException: Your default credentials were not found. To set up Application Default Credentials for your environment, see https://cloud.google.com/docs/authentication/external/set-up-adc.

Caused by: java.lang.IllegalStateException: OAuth2Credentials instance does not support refreshing the access token. An instance with a new access token should be used, or a derived type that supports refreshing.
    at com.google.auth.oauth2.OAuth2Credentials.refreshAccessToken(OAuth2Credentials.java:366)
    at com.google.auth.oauth2.OAuth2Credentials$1.call(OAuth2Credentials.java:269)
    at com.google.auth.oauth2.OAuth2Credentials$1.call(OAuth2Credentials.java:266)
    at java.base/java.util.concurrent.FutureTask.run$$$capture(FutureTask.java:264)
    at java.base/java.util.concurrent.FutureTask.run(FutureTask.java)
    at com.google.auth.oauth2.OAuth2Credentials$RefreshTask.run(OAuth2Credentials.java:633)
    at com.google.common.util.concurrent.DirectExecutor.execute(DirectExecutor.java:31)
    at com.google.auth.oauth2.OAuth2Credentials$AsyncRefreshResult.executeIfNew(OAuth2Credentials.java:581)
    at com.google.auth.oauth2.OAuth2Credentials.asyncFetch(OAuth2Credentials.java:232)
    at com.google.auth.oauth2.OAuth2Credentials.getRequestMetadata(OAuth2Credentials.java:182)
    at com.google.api.gax.rpc.internal.QuotaProjectIdHidingCredentials.getRequestMetadata(QuotaProjectIdHidingCredentials.java:64)
    at com.google.auth.Credentials.blockingGetToCallback(Credentials.java:112)
    at com.google.auth.Credentials$1.run(Credentials.java:98)
    ... 3 more
```
We need to override the CredentialsProvider spring bean:

```java

  @Bean
  @Primary
  public CredentialsProvider credentialsProvider() {
    return () -> NoCredentials.getInstance();
  }

```

The whole configuration can be found in [https://github.com/joerg-pfruender/springbootbigquerytestcontainers/blob/master/src/test/java/com/example/config/GcpTestConfiguration.java](https://github.com/joerg-pfruender/springbootbigquerytestcontainers/blob/master/src/test/java/com/example/config/GcpTestConfiguration.java)


## Problem #3 Ports for testcontainers

When you have solved this, you may receive a `java.net.ConnectException`.

Spring Cloud uses the streaming API for BigQuery. Our BigQuery mock image `ghcr.io/goccy/bigquery-emulator` supports the streaming API, but with one limitation: It needs to know, on which port it runs.

We need to change the `BigQueryEmulatorContainer`, so that the service runs on the same port, on the host AND in the container.

```java

    public BigQueryEmulatorContainer(DockerImageName dockerImageName) {
        super(dockerImageName);
        dockerImageName.assertCompatibleWith(DEFAULT_IMAGE_NAME);
        httpPort = findFreePort();
        grpcPort = findFreePort();
        withCommand("--project="+ PROJECT_ID, "--port="+ httpPort, "--grpc-port="+ grpcPort);
        addFixedExposedPort(httpPort, httpPort);
        addFixedExposedPort(grpcPort, grpcPort);
    }

```

You can find the complete code on 
[https://github.com/joerg-pfruender/springbootbigquerytestcontainers](https://github.com/joerg-pfruender/springbootbigquerytestcontainers)

Pull Request for testcontainers: 
[https://github.com/testcontainers/testcontainers-java/pull/7788](https://github.com/testcontainers/testcontainers-java/pull/7788)

*Any comments or suggestions? Leave an issue or a pull request!*