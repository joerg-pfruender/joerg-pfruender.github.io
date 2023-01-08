---
layout: post
title:  "Nullables as first class deliverable features"
date:   2023-01-08 14:00:00 +0100
categories: [software, testing]
tags: [software, testing, unit tests, mocks, lean, nullables, noestimates]
---

![bridge at construction site](/assets/bridge-g0a6480546_1280.jpg)
<small>Image by <a href="https://pixabay.com/users/projekt_kaffeebart-5458960/">Projekt_Kaffeebart</a> from Pixabay</small>

# The trigger: "Testing without mocks"

Some days ago I read James Shores' paper [Testing without mocks](https://www.jamesshore.com/v2/projects/testing-without-mocks/testing-without-mocks).

It caused different feelings to me, something between "oh cool" and "Please tell me, you're not serious about this".

I tried to imagine the discussions with some of my former colleagues like "I will never have mocks in production code!" and "We don't have time to write Nullable implementations, we need to finish this project, go back to Mockito!" and "You really want to write tests for Nullable implementations?" 

I later read the mastodon thread about it [https://mastodon.online/@jamesshore/109560187641736554](https://mastodon.online/@jamesshore/109560187641736554)
and Michael Williamson's blog post [Reflections on "Testing Without Mocks"](https://mike.zwobble.org/2023/01/reflections-on-testing-without-mocks/).

And then I was reminded of a project on which I worked some years ago....

# "UX first" and "test environment"

Our product owner during that project was really serious about user experience. 
He first wanted us to first build some shiny nice frontend without full functionality.
And he did something like which is now known as "lean software development".

One of his main UX concepts was a **test environment**. This was no extra staging system, but it was a button everyone could click on the production system. 
You can still see this in the software today. 
Look at [https://blog.genopace.de/allgemein/help-center-wissendatenbank-in-baufismart/](https://blog.genopace.de/allgemein/help-center-wissendatenbank-in-baufismart/) and spot "Testumgebung aktivieren" in the right upper corner on the first screenshot.
When a user activated the test environment, everything was safeguarded: He could not mess up with real data and he could not issue real transactions. 

When working inside test environment some users were able to activate different switches that e.g. returned some dummy data instead of real calculations.

The test environment has/had different purposes, I just remember three:

1. usability testing on the real software, trade fair demos etc.
2. training classes
3. automated end-to-end tests on the production system

We still used "normal" unit tests with mockito, but I really liked that approach because it gave us much flexibility during software development.

# #noEstimates and slicing

In my recent years I worked with a different team. 
Every project had a big scope and took many months. 
Someone tried to introduce [#noEstimates](https://oikosofyseries.com/no-estimates-book-order) but within this culture it became a complete disaster.

We were just not able to cut the big scope into small slices and identify minimal viable increments. 
 
# Idea: "Nullables" not only for tests, but as first class deliverable features!

Maybe someone can try to combine these approaches:

* test environment in production software user interface.
* Nullables as first class deliverables e.g. for the test environment. 

Then: 
- Delivering one slice in one day will be easily achievable. That will improve measuring the progress of feature development.
- Developers can code Nullable implementations without debating about their cost*.
- We have better support for manual, explorative testing and automated tests, as well as for demos, trainings etc.

I'm not yet 100% convinced, that we can skip mockito completely. 

But I hope that Nullables will simplify our lives very much.


*) As from the examples given in [https://github.com/jitterted/yacht-tdd](https://github.com/jitterted/yacht-tdd) and [https://github.com/jamesshore/agile2022](https://github.com/jamesshore/agile2022) the code for Nullable implementations is not a big deal, but some developers are able start big arguments about small things. 