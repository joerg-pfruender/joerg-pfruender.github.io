---
layout: post
title:  "Collection of Pitfalls"
date:   2024-08-18 07:00:00 +0100
categories: [software]
tags: [pitfalls]
---

# Beware of pitfalls!

## Github

Anyone can Access Deleted and Private Repository Data on GitHub
[https://trufflesecurity.com/blog/anyone-can-access-deleted-and-private-repo-data-github](https://trufflesecurity.com/blog/anyone-can-access-deleted-and-private-repo-data-github)

## AWS 

### AWS S3

Things you wish you didn't need to know about S3
[https://www.plerion.com/blog/things-you-wish-you-didnt-need-to-know-about-s3](https://www.plerion.com/blog/things-you-wish-you-didnt-need-to-know-about-s3)

### AWS SecretsManager

* Terraform and AWS Secrets Manager: Creating Secrets works fine. Deleting secrets seems to succeed, but the secrets are still there hidden in recovery mode. If you want to create it again, you will get an error: "You can't create this secret because a secret with this name is already scheduled for deletion." Now you are stuck. Solution: Go to the management console, manually restore the secret in recovery mode and [ForceDeleteWithoutRecovery](https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_DeleteSecret.html#API_DeleteSecret_RequestParameters) via aws-cli, see: [https://repost.aws/knowledge-center/delete-secrets-manager-secret](https://repost.aws/knowledge-center/delete-secrets-manager-secret). 
* [Service Quota](https://docs.aws.amazon.com/secretsmanager/latest/userguide/reference_limits.html) of 10000 GetSecretValue requests might seem quite generous, but you can quickly reach this limit with a crash-looping service.
* For reading a secret you do not need only "read-only" privileges but also "secretsmanager:GetSecretValue". Why? Because if you want to see a secret, it does not only read, but also executes a decrypt operation.

## Microsoft Authenticator
Microsoft Authenticator overwrites MFA accounts, locking users out
[https://www.csoonline.com/article/3480918/design-flaw-has-microsoft-authenticator-overwriting-mfa-accounts-locking-users-out.html](https://www.csoonline.com/article/3480918/design-flaw-has-microsoft-authenticator-overwriting-mfa-accounts-locking-users-out.html)

## Java

### Don't use java.util.Date or java.util.Calendar!

[Which date/time class to use?](https://joerg-pfruender.github.io/software/java/2020/01/11/DateTime.html)

### JPA 

[Top 3 JPA Pitfalls](https://joerg-pfruender.github.io/software/2021/12/28/jpa-wtf.html)

### DateFormat is not ThreadSafe
Avoiding Java DateFormat Pitfalls: Best Practices Unveiled
[https://javanexus.com/blog/avoiding-java-dateformat-pitfalls-best-practices](https://javanexus.com/blog/avoiding-java-dateformat-pitfalls-best-practices)

### Unmodifiable Collections 
Unmodifiable Collections expose methods for modifying them. Calling these methods will just result in RuntimeExceptions.

Immutable vs Unmodifiable Collection in Java
[https://www.baeldung.com/java-collection-immutable-unmodifiable-differences](https://www.baeldung.com/java-collection-immutable-unmodifiable-differences)