---
layout: post
title:  "Corona Warn App"
date:   2020-06-16 14:00:00 +0200
categories: [software, corona]
tags: [software, corona, covid-19, app]
---

Ich habe mir heute mal eine Stunde Zeit für einen Schnelldurchflug der [Corona-Warn-App](https://github.com/corona-warn-app) genommen.

Dokumentation angeschaut, Quelltexte heruntergeladen (vor allem die Server-Seite, damit kenne ich mich aus), einiges überflogen und ich muss sagen:

**Der Quelltext macht einen recht guten Eindruck: Gut strukturiert, gut dokumentiert, technisch auf der Höhe der Zeit.**

Wenn man etwas meckern will, dann dass einige Ecken keine automatisierte Testabdeckung haben, aber auch damit wird transparent umgegangen.

# Was macht die App?

Sie läuft immer mit und schneidet mit, mit welchen anderen Apps (bzw. deren Blutooth-Signal) Du Dich triffst:

- Wie lange dauert der Kontakt?
- Wie stark war das Signal? Daraus kann man erraten, wie weit Du von jemand anderem entfernt warst.
- Wann war das?

Wenn beispielsweise Benutzer 5463245634 sich mit COVID-19 infiziert hat, kann er das eintragen und Deine App lädt immer wieder die Liste aller neuen Infektionen vom Server.

Deine App checkt dann: War ich in letzter Zeit in der Nähe von Benutzer 5463245634?

Wenn ja, wird dein Risiko berechnet:
* Wenn Deine App vor 12 Tagen mal 2 Minuten einen Kontakt mit niedrigem Signal mit der App von Benutzer 5463245634 hatte, dann hast Du ein geringes Risiko.
* Wenn Deine App vor drei Tagen eine halbe Stunde lang ein starkes Signal von Benutzer 5463245634 hatte, dann hast Du ein hohes Risiko, dass Du Dich angesteckt hast.

Nach wenigen Wochen werden die Daten dann vom Server gelöscht. Man braucht sie ja dann nicht mehr.

# Die Schwäche

Die Bluetooth-Signalstärke ist kein genauer Maßstab für den Abstand zwischen zwei Menschen. 

Zu Hause bekomme ich z.B. etliche Bluetooth-Signale von den Lautsprecher-Boxen in den Nachbarwohnungen.
Allerdings ist die Bluetooth-Signalstärke das beste, was wir zur Zeit haben. Und es ist sinnvoll eben das zu nehmen, was da ist.

Zu Hause schalte ich aber Bluetooth aus. Das spart Strom und durch die Zimmerdecke werde ich mich sowieso nicht anstecken.

# Fazit

**Installieren!**

**[Google Play](https://play.google.com/store/apps/details?id=de.rki.coronawarnapp)**

**[Apple AppStore](https://apps.apple.com/de/app/corona-warn-app/id1512595757)**
  
Übrigens: Ich habe nirgends gefunden, dass Daten an Bill Gates geschickt werden :-)

*Kommentare oder Kritik? Schreib ein Issue oder einen Pull-Request* 
