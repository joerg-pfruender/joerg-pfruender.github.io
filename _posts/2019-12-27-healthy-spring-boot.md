---
layout: post
title:  "healthy spring boot"
date:   2019-12-22 08:54:31 +0100
categories: jekyll update
categories: [software, microservice]
tags: [spring, boot, health, http, forward]
---

I love standards. Every time you onboard on a new company you will appreciate standards again.
I dislike the "not invented here" syndrome. Have you ever heard: "Yes, usually you do it like this but here in our company we do it like that."?
Then you will know!

A `health` endpoint is a de-facto standard in microservices. In our environment it should be accessable via `/health`, like in [IBMs Healthcheck Tutoral](https://cloud.ibm.com/docs/node?topic=nodejs-node-healthcheck), like it is in Spring Boot 1.x

But in Spring Boot 2.x they moved the default health endpoint to `/actuator/health`. There are plenty of tutorials on how to move the endpoints of the actuator plugin to any other urls. But where will a new employee try to find them? On `/health` or on `/actuator/health`? 

**Can't we just provide both endpoints?**

But how?

### Redirects? Ah...neeee...

A redirect will send an HTTP 30x, but I guess most health checks will just support HTTP 200 status codes.

### Forward

* Using [spring mvc's forward prefix](https://www.logicbig.com/tutorials/spring-framework/spring-web-mvc/forward-prefix.html) simply just didn't work. I guessed the reason is: This technology only works inside of spring mvc and that actuator does not use spring mvc. But I did not dig much deeper into it.
* [Servlet Context forward](https://www.baeldung.com/servlet-redirect-forward) seemed the most promising path. But it resulted in a **NoSuchMethodError**!

        java.lang.NoSuchMethodError: javax.servlet.http.HttpServletRequest.getHttpServletMapping()Ljavax/servlet/http/HttpServletMapping;
            at org.apache.catalina.core.ApplicationHttpRequest.setRequest(ApplicationHttpRequest.java:708) ~[tomcat-embed-core-9.0.29.jar:9.0.29]
            at org.apache.catalina.core.ApplicationHttpRequest.<init>(ApplicationHttpRequest.java:114) ~[tomcat-embed-core-9.0.29.jar:9.0.29]
            at org.apache.catalina.core.ApplicationDispatcher.wrapRequest(ApplicationDispatcher.java:917) ~[tomcat-embed-core-9.0.29.jar:9.0.29]
            at org.apache.catalina.core.ApplicationDispatcher.doForward(ApplicationDispatcher.java:358) ~[tomcat-embed-core-9.0.29.jar:9.0.29]
            at org.apache.catalina.core.ApplicationDispatcher.forward(ApplicationDispatcher.java:312) ~[tomcat-embed-core-9.0.29.jar:9.0.29]
            at ForwardingController.forwardHealth(ForwardingController.java:19) ~[classes/:na]
            at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method) ~[na:1.8.0_191]
            at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:62) ~[na:1.8.0_191]
            at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43) ~[na:1.8.0_191]
            at java.lang.reflect.Method.invoke(Method.java:498) ~[na:1.8.0_191]
            at org.springframework.web.method.support.InvocableHandlerMethod.doInvoke(InvocableHandlerMethod.java:190) ~[spring-web-5.2.2.RELEASE.jar:5.2.2.RELEASE]
            at org.springframework.web.method.support.InvocableHandlerMethod.invokeForRequest(InvocableHandlerMethod.java:138) ~[spring-web-5.2.2.RELEASE.jar:5.2.2.RELEASE]
            at org.springframework.web.servlet.mvc.method.annotation.ServletInvocableHandlerMethod.invokeAndHandle(ServletInvocableHandlerMethod.java:106) ~[spring-webmvc-5.2.2.RELEASE.jar:5.2.2.RELEASE]
            at org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerAdapter.invokeHandlerMethod(RequestMappingHandlerAdapter.java:888) ~[spring-webmvc-5.2.2.RELEASE.jar:5.2.2.RELEASE]
            at org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerAdapter.handleInternal(RequestMappingHandlerAdapter.java:793) ~[spring-webmvc-5.2.2.RELEASE.jar:5.2.2.RELEASE]
            at org.springframework.web.servlet.mvc.method.AbstractHandlerMethodAdapter.handle(AbstractHandlerMethodAdapter.java:87) ~[spring-webmvc-5.2.2.RELEASE.jar:5.2.2.RELEASE]
            at org.springframework.web.servlet.DispatcherServlet.doDispatch(DispatcherServlet.java:1040) ~[spring-webmvc-5.2.2.RELEASE.jar:5.2.2.RELEASE]
            at org.springframework.web.servlet.DispatcherServlet.doService(DispatcherServlet.java:943) ~[spring-webmvc-5.2.2.RELEASE.jar:5.2.2.RELEASE]
            at org.springframework.web.servlet.FrameworkServlet.processRequest(FrameworkServlet.java:1006) ~[spring-webmvc-5.2.2.RELEASE.jar:5.2.2.RELEASE]
            at org.springframework.web.servlet.FrameworkServlet.doGet(FrameworkServlet.java:898) ~[spring-webmvc-5.2.2.RELEASE.jar:5.2.2.RELEASE]
            at javax.servlet.http.HttpServlet.service(HttpServlet.java:687) ~[wiremock-standalone-2.20.0.jar:na]
            at org.springframework.web.servlet.FrameworkServlet.service(FrameworkServlet.java:883) ~[spring-webmvc-5.2.2.RELEASE.jar:5.2.2.RELEASE]
            at javax.servlet.http.HttpServlet.service(HttpServlet.java:790) ~[wiremock-standalone-2.20.0.jar:na]
            at org.apache.catalina.core.ApplicationFilterChain.internalDoFilter(ApplicationFilterChain.java:231) ~[tomcat-embed-core-9.0.29.jar:9.0.29]
            at org.apache.catalina.core.ApplicationFilterChain.doFilter(ApplicationFilterChain.java:166) ~[tomcat-embed-core-9.0.29.jar:9.0.29]
            at org.apache.tomcat.websocket.server.WsFilter.doFilter(WsFilter.java:53) ~[tomcat-embed-websocket-9.0.29.jar:9.0.29]
            at org.apache.catalina.core.ApplicationFilterChain.internalDoFilter(ApplicationFilterChain.java:193) ~[tomcat-embed-core-9.0.29.jar:9.0.29]
            at org.apache.catalina.core.ApplicationFilterChain.doFilter(ApplicationFilterChain.java:166) ~[tomcat-embed-core-9.0.29.jar:9.0.29]
            at org.springframework.security.web.FilterChainProxy$VirtualFilterChain.doFilter(FilterChainProxy.java:320) ~[spring-security-web-5.2.1.RELEASE.jar:5.2.1.RELEASE]
            at org.springframework.security.web.access.intercept.FilterSecurityInterceptor.invoke(FilterSecurityInterceptor.java:126) ~[spring-security-web-5.2.1.RELEASE.jar:5.2.1.RELEASE]
            at org.springframework.security.web.access.intercept.FilterSecurityInterceptor.doFilter(FilterSecurityInterceptor.java:90) ~[spring-security-web-5.2.1.RELEASE.jar:5.2.1.RELEASE]
            at org.springframework.security.web.FilterChainProxy$VirtualFilterChain.doFilter(FilterChainProxy.java:334) ~[spring-security-web-5.2.1.RELEASE.jar:5.2.1.RELEASE]
            at org.springframework.security.web.access.ExceptionTranslationFilter.doFilter(ExceptionTranslationFilter.java:118) ~[spring-security-web-5.2.1.RELEASE.jar:5.2.1.RELEASE]
            at org.springframework.security.web.FilterChainProxy$VirtualFilterChain.doFilter(FilterChainProxy.java:334) ~[spring-security-web-5.2.1.RELEASE.jar:5.2.1.RELEASE]
            at org.springframework.security.web.session.SessionManagementFilter.doFilter(SessionManagementFilter.java:137) ~[spring-security-web-5.2.1.RELEASE.jar:5.2.1.RELEASE]
            at org.springframework.security.web.FilterChainProxy$VirtualFilterChain.doFilter(FilterChainProxy.java:334) ~[spring-security-web-5.2.1.RELEASE.jar:5.2.1.RELEASE]
            at org.springframework.security.web.authentication.AnonymousAuthenticationFilter.doFilter(AnonymousAuthenticationFilter.java:111) ~[spring-security-web-5.2.1.RELEASE.jar:5.2.1.RELEASE]
            at org.springframework.security.web.FilterChainProxy$VirtualFilterChain.doFilter(FilterChainProxy.java:334) ~[spring-security-web-5.2.1.RELEASE.jar:5.2.1.RELEASE]
            at org.springframework.security.web.servletapi.SecurityContextHolderAwareRequestFilter.doFilter(SecurityContextHolderAwareRequestFilter.java:158) ~[spring-security-web-5.2.1.RELEASE.jar:5.2.1.RELEASE]
            at org.springframework.security.web.FilterChainProxy$VirtualFilterChain.doFilter(FilterChainProxy.java:334) ~[spring-security-web-5.2.1.RELEASE.jar:5.2.1.RELEASE]
            at org.springframework.security.web.savedrequest.RequestCacheAwareFilter.doFilter(RequestCacheAwareFilter.java:63) ~[spring-security-web-5.2.1.RELEASE.jar:5.2.1.RELEASE]
            at org.springframework.security.web.FilterChainProxy$VirtualFilterChain.doFilter(FilterChainProxy.java:334) ~[spring-security-web-5.2.1.RELEASE.jar:5.2.1.RELEASE]
            at org.springframework.security.web.authentication.www.BasicAuthenticationFilter.doFilterInternal(BasicAuthenticationFilter.java:154) ~[spring-security-web-5.2.1.RELEASE.jar:5.2.1.RELEASE]
            at org.springframework.web.filter.OncePerRequestFilter.doFilter(OncePerRequestFilter.java:119) ~[spring-web-5.2.2.RELEASE.jar:5.2.2.RELEASE]
            at org.springframework.security.web.FilterChainProxy$VirtualFilterChain.doFilter(FilterChainProxy.java:334) ~[spring-security-web-5.2.1.RELEASE.jar:5.2.1.RELEASE]
            at org.springframework.security.web.authentication.logout.LogoutFilter.doFilter(LogoutFilter.java:116) ~[spring-security-web-5.2.1.RELEASE.jar:5.2.1.RELEASE]
            at org.springframework.security.web.FilterChainProxy$VirtualFilterChain.doFilter(FilterChainProxy.java:334) ~[spring-security-web-5.2.1.RELEASE.jar:5.2.1.RELEASE]
            at org.springframework.web.filter.CorsFilter.doFilterInternal(CorsFilter.java:92) ~[spring-web-5.2.2.RELEASE.jar:5.2.2.RELEASE]
            at org.springframework.web.filter.OncePerRequestFilter.doFilter(OncePerRequestFilter.java:119) ~[spring-web-5.2.2.RELEASE.jar:5.2.2.RELEASE]
            at org.springframework.security.web.FilterChainProxy$VirtualFilterChain.doFilter(FilterChainProxy.java:334) ~[spring-security-web-5.2.1.RELEASE.jar:5.2.1.RELEASE]
            at org.springframework.security.web.header.HeaderWriterFilter.doHeadersAfter(HeaderWriterFilter.java:92) ~[spring-security-web-5.2.1.RELEASE.jar:5.2.1.RELEASE]
            at org.springframework.security.web.header.HeaderWriterFilter.doFilterInternal(HeaderWriterFilter.java:77) ~[spring-security-web-5.2.1.RELEASE.jar:5.2.1.RELEASE]
            at org.springframework.web.filter.OncePerRequestFilter.doFilter(OncePerRequestFilter.java:119) ~[spring-web-5.2.2.RELEASE.jar:5.2.2.RELEASE]
            at org.springframework.security.web.FilterChainProxy$VirtualFilterChain.doFilter(FilterChainProxy.java:334) ~[spring-security-web-5.2.1.RELEASE.jar:5.2.1.RELEASE]
            at org.springframework.security.web.context.SecurityContextPersistenceFilter.doFilter(SecurityContextPersistenceFilter.java:105) ~[spring-security-web-5.2.1.RELEASE.jar:5.2.1.RELEASE]
            at org.springframework.security.web.FilterChainProxy$VirtualFilterChain.doFilter(FilterChainProxy.java:334) ~[spring-security-web-5.2.1.RELEASE.jar:5.2.1.RELEASE]
            at org.springframework.security.web.context.request.async.WebAsyncManagerIntegrationFilter.doFilterInternal(WebAsyncManagerIntegrationFilter.java:56) ~[spring-security-web-5.2.1.RELEASE.jar:5.2.1.RELEASE]
            at org.springframework.web.filter.OncePerRequestFilter.doFilter(OncePerRequestFilter.java:119) ~[spring-web-5.2.2.RELEASE.jar:5.2.2.RELEASE]
            at org.springframework.security.web.FilterChainProxy$VirtualFilterChain.doFilter(FilterChainProxy.java:334) ~[spring-security-web-5.2.1.RELEASE.jar:5.2.1.RELEASE]
            at org.springframework.security.web.FilterChainProxy.doFilterInternal(FilterChainProxy.java:215) ~[spring-security-web-5.2.1.RELEASE.jar:5.2.1.RELEASE]
            at org.springframework.security.web.FilterChainProxy.doFilter(FilterChainProxy.java:178) ~[spring-security-web-5.2.1.RELEASE.jar:5.2.1.RELEASE]
            at org.springframework.web.filter.DelegatingFilterProxy.invokeDelegate(DelegatingFilterProxy.java:358) ~[spring-web-5.2.2.RELEASE.jar:5.2.2.RELEASE]
            at org.springframework.web.filter.DelegatingFilterProxy.doFilter(DelegatingFilterProxy.java:271) ~[spring-web-5.2.2.RELEASE.jar:5.2.2.RELEASE]
            at org.apache.catalina.core.ApplicationFilterChain.internalDoFilter(ApplicationFilterChain.java:193) ~[tomcat-embed-core-9.0.29.jar:9.0.29]
            at org.apache.catalina.core.ApplicationFilterChain.doFilter(ApplicationFilterChain.java:166) ~[tomcat-embed-core-9.0.29.jar:9.0.29]
            at org.springframework.web.filter.RequestContextFilter.doFilterInternal(RequestContextFilter.java:100) ~[spring-web-5.2.2.RELEASE.jar:5.2.2.RELEASE]
            at org.springframework.web.filter.OncePerRequestFilter.doFilter(OncePerRequestFilter.java:119) ~[spring-web-5.2.2.RELEASE.jar:5.2.2.RELEASE]
            at org.apache.catalina.core.ApplicationFilterChain.internalDoFilter(ApplicationFilterChain.java:193) ~[tomcat-embed-core-9.0.29.jar:9.0.29]
            at org.apache.catalina.core.ApplicationFilterChain.doFilter(ApplicationFilterChain.java:166) ~[tomcat-embed-core-9.0.29.jar:9.0.29]
            at org.springframework.web.filter.FormContentFilter.doFilterInternal(FormContentFilter.java:93) ~[spring-web-5.2.2.RELEASE.jar:5.2.2.RELEASE]
            at org.springframework.web.filter.OncePerRequestFilter.doFilter(OncePerRequestFilter.java:119) ~[spring-web-5.2.2.RELEASE.jar:5.2.2.RELEASE]
            at org.apache.catalina.core.ApplicationFilterChain.internalDoFilter(ApplicationFilterChain.java:193) ~[tomcat-embed-core-9.0.29.jar:9.0.29]
            at org.apache.catalina.core.ApplicationFilterChain.doFilter(ApplicationFilterChain.java:166) ~[tomcat-embed-core-9.0.29.jar:9.0.29]
            at org.springframework.boot.actuate.metrics.web.servlet.WebMvcMetricsFilter.doFilterInternal(WebMvcMetricsFilter.java:108) ~[spring-boot-actuator-2.2.2.RELEASE.jar:2.2.2.RELEASE]
            at org.springframework.web.filter.OncePerRequestFilter.doFilter(OncePerRequestFilter.java:119) ~[spring-web-5.2.2.RELEASE.jar:5.2.2.RELEASE]
            at org.apache.catalina.core.ApplicationFilterChain.internalDoFilter(ApplicationFilterChain.java:193) ~[tomcat-embed-core-9.0.29.jar:9.0.29]
            at org.apache.catalina.core.ApplicationFilterChain.doFilter(ApplicationFilterChain.java:166) ~[tomcat-embed-core-9.0.29.jar:9.0.29]
            at org.springframework.web.filter.CharacterEncodingFilter.doFilterInternal(CharacterEncodingFilter.java:201) ~[spring-web-5.2.2.RELEASE.jar:5.2.2.RELEASE]
            at org.springframework.web.filter.OncePerRequestFilter.doFilter(OncePerRequestFilter.java:119) ~[spring-web-5.2.2.RELEASE.jar:5.2.2.RELEASE]
            at org.apache.catalina.core.ApplicationFilterChain.internalDoFilter(ApplicationFilterChain.java:193) ~[tomcat-embed-core-9.0.29.jar:9.0.29]
            at org.apache.catalina.core.ApplicationFilterChain.doFilter(ApplicationFilterChain.java:166) ~[tomcat-embed-core-9.0.29.jar:9.0.29]
            at org.apache.catalina.core.StandardWrapperValve.invoke(StandardWrapperValve.java:202) ~[tomcat-embed-core-9.0.29.jar:9.0.29]
            at org.apache.catalina.core.StandardContextValve.invoke(StandardContextValve.java:96) [tomcat-embed-core-9.0.29.jar:9.0.29]
            at org.apache.catalina.authenticator.AuthenticatorBase.invoke(AuthenticatorBase.java:526) [tomcat-embed-core-9.0.29.jar:9.0.29]
            at org.apache.catalina.core.StandardHostValve.invoke(StandardHostValve.java:139) [tomcat-embed-core-9.0.29.jar:9.0.29]
            at org.apache.catalina.valves.ErrorReportValve.invoke(ErrorReportValve.java:92) [tomcat-embed-core-9.0.29.jar:9.0.29]
            at org.apache.catalina.core.StandardEngineValve.invoke(StandardEngineValve.java:74) [tomcat-embed-core-9.0.29.jar:9.0.29]
            at org.apache.catalina.connector.CoyoteAdapter.service(CoyoteAdapter.java:343) [tomcat-embed-core-9.0.29.jar:9.0.29]
            at org.apache.coyote.http11.Http11Processor.service(Http11Processor.java:367) [tomcat-embed-core-9.0.29.jar:9.0.29]
            at org.apache.coyote.AbstractProcessorLight.process(AbstractProcessorLight.java:65) [tomcat-embed-core-9.0.29.jar:9.0.29]
            at org.apache.coyote.AbstractProtocol$ConnectionHandler.process(AbstractProtocol.java:860) [tomcat-embed-core-9.0.29.jar:9.0.29]
            at org.apache.tomcat.util.net.NioEndpoint$SocketProcessor.doRun(NioEndpoint.java:1591) [tomcat-embed-core-9.0.29.jar:9.0.29]
            at org.apache.tomcat.util.net.SocketProcessorBase.run(SocketProcessorBase.java:49) [tomcat-embed-core-9.0.29.jar:9.0.29]
            at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1149) [na:1.8.0_191]
            at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624) [na:1.8.0_191]
            at org.apache.tomcat.util.threads.TaskThread$WrappingRunnable.run(TaskThread.java:61) [tomcat-embed-core-9.0.29.jar:9.0.29]
            at java.lang.Thread.run(Thread.java:748)


**Wait! A NoSuchMethodError?**

Yes. Obviously the default method `getHttpServletMapping()` did not make it from the interface into the implementing class in the embedded tomcat.

Luckily the apache folks already have an new version available. You simply need to patch the dependencies of your spring boot project:

    implementation 'org.apache.tomcat.embed:tomcat-embed-core:9.0.30' // standard version 9.0.29 that comes with spring boot 2.2.2 has a bug
    implementation 'org.apache.tomcat.embed:tomcat-embed-el:9.0.30' // standard version 9.0.29 that comes with spring boot 2.2.2 has a bug
    implementation 'org.apache.tomcat.embed:tomcat-embed-websocket:9.0.30' // standard version 9.0.29 that comes with spring boot 2.2.2 has a bug

(build.gradle)


Then it works!


*Any comments or suggestions? Leave an issue or a pull request!*