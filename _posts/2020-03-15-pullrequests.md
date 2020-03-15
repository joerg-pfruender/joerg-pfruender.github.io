---
layout: post
title:  "Streiterei bei Pull-Requests (German)"
date:   2020-03-01 17:05:00 +0100
categories: [software, collaboration, Zusammenarbeit]
tags: [software, pull requests, merge requests]
---

![Goats](/assets/goats.jpg)

<small>Bild von [hbieser&#8599;](https://pixabay.com/de/users/hbieser-343207/?utm_source=link-attribution) auf [Pixabay&#8599;](https://pixabay.com/de/?utm_source=link-attribution)</small>

## Warum ist der Ton in der Softwareentwicklung so rauh geworden?

Seit einigen Jahren ist es üblich geworden mit Pull-Requests (Merge-Requests) zu arbeiten. 
Wo wir früher oft „einfach so“ Code geschrieben haben,
haben wir durch das 4-Augen-Prinzip jetzt die Chance auf eine deutlich bessere Codequalität.
Leider hat sich aber gefühlt das Klima in den Teams verschlechtert. 

## Versuch einer Erklärung

Der Reviewer des Codes sieht sich oft als eine Art „Wächter“ des guten Codes. 
Es geht nicht nur um echte Fehler. Auch die Lesbarkeit und Wartbarkeit spielt eine Rolle. 
Dazu gibt es viele verschieden Leitlinien: [DRY (Don‘t repeat yourself)](https://de.wikipedia.org/wiki/Don%E2%80%99t_repeat_yourself), [SOLID](https://de.wikipedia.org/wiki/Prinzipien_objektorientierten_Designs#SOLID-Prinzipien) u.s.w. . 
Oft muss man aber auch zwischen zwei Lösungen abwägen, die jede andere Vor- und Nachteile bringt: 
Soll ich wirklich die Bibliothek x,y einbinden, oder vielleicht lieber die Funktionalität nochmal selbst (ab-)schreiben (DRY and [dependency hell](https://en.wikipedia.org/wiki/Dependency_hell))?
Soll ich eine Klasse oder Methode rausrefactorn, um sie wiederverwenden zu können, oder ist es besser die Sache ein zweites Mal ähnlich zu implementieren? (Aufwand und Nutzen von [Wiederverwendung](https://de.wikipedia.org/wiki/Wiederverwendbarkeit) vs. [Simplizität der Implementierung](https://de.wikipedia.org/wiki/KISS-Prinzip)). 
In Pull-Requests sind oft zwei Leute unterschiedlicher Meinung und dann wird lange diskutiert über die Vor- und Nachteile der einen oder anderen Lösung. 
Wir sind oft zu verliebt in unsere eigene Lösung. 
Und wir sind groß im Kritisieren und Rechthaben.

Dem einen geht das DRY-Prinzip über alles, dem anderen sind andere Dinge wichtiger. Der eine will sich dem Code-Stil anpassen, das er in dem Projekt vorgefunden hat, auch wenn er es nicht perfekt findet (Principle of least astonishment). Der andere besteht darauf, dass neuer Code den (seinen) neuesten Erkenntnissen entspricht. 

Was können wir ändern? Sieben Vorschläge!

## 1. Lobe gute Lösungen

Wir sind immer schnell beim Kritisieren. 
Haben wir jemanden im Zuge eines Pull-Requests schon mal für seine Lösung gelobt? 
Man sagt, in [guten Beziehungen besteht das Verhältnis von Lob zu Tadel 5:1](https://verhalten.wordpress.com/2013/11/22/lob-und-tadel-5-zu-1/). 
In unseren Code-Reviews ist das Verhältnis eher 0:5. 
Ich weiß, es ist schwierig in einem Code-Review zu loben, 
aber ich bemühe mich, auch wenn die Codequalität sonst eher durchwachsen ist, 
mindestens ein Lob unterzubringen.

## 2. Richtlinien sind keine Gesetze

Richtlinien wie DRY und SOLID sind generell gute Regeln, 
jede von ihnen hat aber auch ihre Grenzen. 
Oft muss die eine Regel gegen eine andere abgewogen werden und unterschiedliche Leute kommen da zu unterschiedlichen Ergebnissen. 
Sei bereit über deine Ansicht von „gutem Code“ zu reden und sie argumentativ gegen andere Prinzipien abzuwägen. 
Schmettere deine Regel dem Kollegen nicht als Totschlagargument entgegen!
 

## 3. Postel‘s Law für menschliche Interaktion verwenden: [„Be conservative in what you do, be liberal in what you accept from others“](https://de.wikipedia.org/wiki/Robustheitsgrundsatz)

Durch eine konstruktive Diskussion kann die Codequalität verbessert werden.
Auch die Einhaltung von offiziellen Coding-Richtlinien muss überprüft werden.

Pull-Requests sind aber nicht der richtige Ort für Rechthaber-Diskussionen. 
Wenn der andere einen anderen Code-Stil pflegt wie du, dann ist das ok. 
Solange keine Gefahr und kein Risiko für das Projekt besteht, 
muss nicht der Stil jeder Codezeile durchdiskutiert werden.

## 4. Mache Vorschläge

Wenn du findest, dass du eine bessere Lösung für das Problem hast, 
dann implementiere doch einen Alternativvorschlag und stelle den zur Diskussion, 
anstatt einfach nur zu kritisieren.

## 5. Unterscheide zwischen „geht gar nicht“ und „es wäre besser, wenn“

Es gibt risikoreiche Implementierungen, die muss ein Reviewer zurückweisen. 
Es gibt aber auch Dinge, bei denen du denkst, 
die aktuelle Implementierung ist zwar auch ok, keine Katastrophe, 
aber es ginge sehr viel besser. Dann markiere das auch so. 
Schreibe, dass du das so-und-so lösen würdest, das hätte dann die-und-die Vorteile.
Schreibe aber auch, dass dieser Verbesserungsvorschlag optional ist und nicht übernommen werden muss. 

## 6. Benutze auch mal deine IDE

Ich persönlich kann in dem eingebauten Review-Editor von [Gitlab](https://gitlab.com/explore) viele Codeänderungen nicht verstehen, 
die ich bspw. in IntellijIDEA in der Code-Diff-Ansicht von zwei Branches auf den ersten kapiere.
 

## 7. Nimm auch mal den Telefonhörer

Manches kann man einfacher in der direkten Interaktion klären als mit einem Nachrichten-Ping-Pong an einem Pull-Request.
Telefon und Videokonferenz mit geöffnetem Code sind oft hilfreich.

Irgendwelche Kommentare, Hinweise, Vorschläge? Schreibe ein Issue oder einen Pull-Request :-) 