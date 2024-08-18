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

* For reading a secret you do not need only "read-only" privileges but also "secretsmanager:GetSecretValue". Why? Because if you want to see a secret, it does not only read, but also executes a decrypt operation.
* [Service Quota](https://docs.aws.amazon.com/secretsmanager/latest/userguide/reference_limits.html) of 10000 GetSecretValue requests might seem quite generous, but you can quickly reach this limit with a crash-looping service. 

## Microsoft Authenticator
Microsoft Authenticator overwrites MFA accounts, locking users out
[https://www.csoonline.com/article/3480918/design-flaw-has-microsoft-authenticator-overwriting-mfa-accounts-locking-users-out.html](https://www.csoonline.com/article/3480918/design-flaw-has-microsoft-authenticator-overwriting-mfa-accounts-locking-users-out.html)

## Java

### Don't use java.util.Date or java.util.Calendar!

[Which date/time class to use?](https://joerg-pfruender.github.io/software/java/2020/01/11/DateTime.html)

### JPA 

[Top 3 JPA Pitfalls](https://joerg-pfruender.github.io/software/2021/12/28/jpa-wtf.html)
