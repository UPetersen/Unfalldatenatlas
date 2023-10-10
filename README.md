# Unfalldatenatlas Deutschland

Diese App zeigt mehr als 1,5 Millionen polizeilich registrierte Verkehrsunfälle mit getöteten oder verletzen Personen der Jahre 2016 bis 2022 auf einer Deutschlandkarte an. Zu den einzelnen Unfällen können verschiedene Attribute wie z.B. Unfallart und -typ oder Unfallbeteiligte (Pkw, Fahrrad, Fußgänger etc.) eingeblendet werden. Zudem können die angezeigten Unfälle nach vielen Attributen gefiltert werden. So lassen sich die angzeigten Unfälle z.B. auf alle Fahrunfälle mit Getöteten und Beteiligung von Krafträdern bei feucht/nass/schlüpfrigem Straßenzustand einschränken.
            
<p align="center">
<img width="400" src="https://github.com/UPetersen/Unfalldatenatlas/assets/10375483/363e952f-2de2-4e65-a769-e2f8d3895486">
</p>


## Einschränkungen

Diese App ist ein **Hobbyprojekt**, [Open Source](https://github.com/UPetersen/Unfalldatenatlas) und kostenlos für iPhone und iPad (ab iOS 17) sowie Mac verfügbar. Nicht alles ist perfekt, manchmal ruckelt es. Bitte berücksichtigen Sie das bei eventuellen Bewertungen.
            
Bitte beachten Sie, dass maximal 400 Unfälle im Kartenausschnitt angezeigt werden. Um alle Unfälle in einem Kartenausschnitt zu sehen, muss daher ggf. weiter hineingezoomt werden. Für große Kartenausschnitte wie ganz Deutschland wirkt die Anzeige meist etwas willkürlich, weil dann meist nur Unfälle in einem Bundesland angezeigt werden. 

Die Unfalldaten stammen vom [Unfallatlas](https://unfallatlas.statistikportal.de) des statistischen Bundesamts (DESTATIS) und sind im Download der App im Originalformat enthalten. Die Unfalldaten werden beim erstmaligen Start der App in eine lokale Datenbank umgespeichert und für schnelleren Zugriff vielfältig indexiert. Dies ist ein einmaliger Vorgang und dauert leider einige Minuten. Sollte der Vorgang nicht abgeschlossen werden, wird er beim nächsten Start wiederholt. Bitte also Geduld, die App kann in dieser Zeit auch schon benutzt werden.

            
## Anzeige von Detailinformationen zu Unfällen <img height="20" style="vertical-align:middle;" src="https://github.com/UPetersen/Unfalldatenatlas/assets/10375483/ee97a788-6a45-4db6-88ce-ad6e3c0a933c">

Die einzelnen Unfälle werden auf der Karte am Unfallort durch Kreise angezeigt, die entsprechend [der Farbskala für Unfalltypen](https://de.wikipedia.org/wiki/Unfalltyp) eingefärbt sind.

<p align="center">
<img width="400" src="https://github.com/UPetersen/Unfalldatenatlas/assets/10375483/105b7c8c-0aa3-4436-998c-d2e14908521b">
</p>

<!--- Auskommentiert: Beispiel für Bild mit Bildunterschrift
<figure>
  <img src="{https://github.com/UPetersen/Unfalldatenatlas/assets/10375483/105b7c8c-0aa3-4436-998c-d2e14908521b" alt="my alt text"/>
  <figcaption>This is my caption text.</figcaption>
</figure>
--->

Zusätzlich kann über den Button <img height="15" style="vertical-align:middle;" src="https://github.com/UPetersen/Unfalldatenatlas/assets/10375483/ee97a788-6a45-4db6-88ce-ad6e3c0a933c"> auf eine detaillierte Darstellung umgeschaltet werden, bei der über Text und Emoji-Symbole Zusatzinformationen zu jedem einzelnen Unfall angezeigt werden, z.B. 

<p align="center">
<img width="450" alt="Bildschirmfoto 2023-10-01 um 11 16 19" src="https://github.com/UPetersen/Unfalldatenatlas/assets/10375483/7b3caf99-a62a-4b8d-b77c-3771289566c3">
</p>

für einen Unfall des Typs *Einbiegen-/Kreuzen-Unfall* (⭕️) im Jahr 2016 mit Beteiligung mindestens eines Pkws (🚗) und Radfahrers (🚴) bei Dunkelheit (🌝), nass/feucht/schlüpfrigem Straßenzustand (🌧️) mit Schwerverletzen (🏥) und Unfallart *Zusammenstoß mit einem einbiegendem/kreuzendem Fahrzeug* (A5)

Nachfolgend sind die möglichen Zusatzinformationen im Detail beschrieben, die man auch in der App über den Button <img height="15" style="vertical-align:middle;" src="https://github.com/UPetersen/Unfalldatenatlas/assets/10375483/094d784e-5935-460c-9ee0-ad8007209d35"> erhalten kann.
            
### Unfalljahr

Die letzten zwei Ziffern des Unfalljahres, z.B. 
- "16" für das Jahr 2016,
- "17" für das Jahr 2017
- ...
            
### Unfallbeteiligte

- 🚗 für Unfälle, an denen mindestens ein Pkw beteiligt war.
- 🏍️ für Unfälle, an denen mindestens ein Kraftrad (z.B. Mofa, Motorrad/-roller) beteiligt war.
- 🚴 für Unfälle, an denen mindestens ein Fahrrad beteiligt war.
- 🚶‍♂️ für Unfälle, an denen mindestens ein Fußgänger(in) beteiligt war.
- 🚚 für Unfälle, an denen mindestens ein Lastkraftwagen mit Normalaufbau und einem Gesamtgewicht über 3,5 t, ein Lastkraftwagen mit Tankauflage bzw. Spezialaufbau,eine Sattelzugmaschine oder eine andere Zugmaschine beteiligt war (diese Kategorie ist in den Jahren 2016 und 2017 in der nachfolgenden Kategorie enthalten)
- 🚚/🚌/🚃 bzw. 🚌/🚃 (ab 2018) für Unfälle an denen mindestens ein oben nicht genanntes Verkehrsmittel beteiligt war, wie z.B. ein Bus oder eine Straßenbahn. Für die Jahre 2016 und 2017 einschließlich Unfall mit Güterkraftfahrzeug, ab 2018 ohne Güterkraftfahrzeuge.

                        
### Lichtverhältnisse
            
- 🌛 für Unfälle bei Dämmerung und
- 🌝 für Unfälle bei Dunkelheit.
- Wird nichts angezeigt war der Unfall bei Tageslicht.      
            
### Straßenzustand

- 🌧️ für nass/feucht/schlüpfrigen Straßenzustand,
- ❄️ für winterglatten Straßenzustand.
- Wird nichts angezeigt war der Unfall bei trockenem Straßenzustand.
       
            
### Verletzungsschwere

- ✟ für Unfälle mit Getöteten, d.h. Personen, die innerhalb von 30 Tagen an den Unfallfolgen starben.
- 🏥 für Unfälle mit Schwerverletzten, d.h. Personen, die unmittelbar zur stationären Behandlung (mindestens 24 Stunden) in einem Krankenhaus aufgenommen wurden.
- 🩹 für Unfälle mit Leichtverletzten, d.h. alle übrigen Verletzten.


### Unfallart

Siehe [hier](https://www.destatis.de/DE/Themen/Gesellschaft-Umwelt/Verkehrsunfaelle/Methoden/_inhalt.html#sprg371798) zu weiteren Informationen zu Unfallarten.

- A1 für Zusammenstoß mit anfahrendem/anhaltendem/ruhendem Fahrzeug.
- A2 für Zusammenstoß mit vorausfahrendem/wartendem Fahrzeug.
- A3 für Zusammenstoß mit seitlich in gleicher Richtung fahrendem Fahrzeug.
- A4 für Zusammenstoß mit entgegenkommendem Fahrzeug.
- A5 für Zusammenstoß mit einbiegendem/kreuzendem Fahrzeug.
- A6 für Zusammenstoß zwischen Fahrzeug und Fußgänger.
- A7 für Aufprall auf Fahrbahnhindernis.
- A8 für Abkommen von der Fahrbahn nach rechts.
- A9 für Abkommen von der Fahrbahn nach links.
- A0 für Unfälle anderer Art.

## "Lookaround"-Ansicht des Unfallorts <img height="25" style="vertical-align:middle;" src="https://github.com/UPetersen/Unfalldatenatlas/assets/10375483/db2d93e4-593f-496a-a334-fc9cebfbb0ba">

Über den Button  <img height="16" style="vertical-align:bottom;" src="https://github.com/UPetersen/Unfalldatenatlas/assets/10375483/db2d93e4-593f-496a-a334-fc9cebfbb0ba"> lässt sich eine statische Voransicht des Unfallorts bzw. Straßenabschnitts zuschalten, wie sie auch in Apple Maps verfügbar ist. Durch Klicken auf einen Unfall in der Karte wird dann die entsprechende Voransicht für diesen Unfallort geladen und im unteren Bereich angezeigt. Durch anschließendes Klicken auf diese Voransicht kann auf eine vollständige Lookaround-Ansicht umgeschaltet werden, in der man sich mit den üblichen Gesten umschauen bzw. entlang der Straße bewegen kann. Erstaunlicherweise ist diese Ansicht für sehr viele Straßen und damit Unfallorte verfügbar.

<p align="middle">
  <img width="300" src="https://github.com/UPetersen/Unfalldatenatlas/assets/10375483/10008c90-6208-453e-b051-7b0650ebb1ee" /> 
  <img width="300" src="https://github.com/UPetersen/Unfalldatenatlas/assets/10375483/deaf8333-089a-4efb-984e-d59038bc3939" />
</p>

## Datenauswahl bzw. -filterung <img height="25" style="vertical-align:middle;" src="https://github.com/UPetersen/Unfalldatenatlas/assets/10375483/e353808f-5d78-4126-98a3-f617d915c416">
            
Oben links in der App wird die Zahl aller selektierten Unfälle angezeigt. Beim Start der App sind das 1.554.384 Unfälle, alle die in der Datenbank gespeichert sind. Über das Menü  <img height="16" style="vertical-align:bottom;" src="https://github.com/UPetersen/Unfalldatenatlas/assets/10375483/e353808f-5d78-4126-98a3-f617d915c416">  kann die Auswahl vielfältig auf bestimmte Unfälle eingegrenzt werden, z.B. auf alle Unfälle mit Getöteten. Entsprechend wird oben links die Zahl der Unfälle auf diese Auswahl reduziert, im Beispiel für alle Unfälle mit Getöteten auf 15.578 entsprechende Unfälle die in der Datenbank enthalten sind. Entsprechend werden im Kartenausschnitt auch nur noch Unfälle mit Getöteten angezeigt.

<p align="center">
<img width="400" src="https://github.com/UPetersen/Unfalldatenatlas/assets/10375483/e03a69c8-bb3f-4e61-8b8a-a486fa12bfd3">
</p>

Neben den Daten der Detailanzeige (Unfalljahr, Unfallbeteiligte, Lichtverhältnisse, Straßenzustand, Verletzungsschwere und Unfallart) lassen sich dabei auch der Wochentag, der Monat sowie das Bundesland auswählen bzw. eingrenzen. Alle diese Kategorien lassen sich beliebig verknüpfen, z.B. Unfälle mit Getöteten und Beteiligung von Pkw- und Radfahrern bei Nacht oder Fahrunfälle mit Beteiligung von Krafträdern ohne Beteiligung von Pkw et Cetera. Mehrfachauswahlen innerhalb einer Kategorie, z.B. Unfälle die sich an Samstagen oder Sonntagen ereigneten sind noch nicht implementiert.

<p align="center">
<img width=400" src="https://github.com/UPetersen/Unfalldatenatlas/assets/10375483/39bfbd7c-0d9a-4827-9d74-babb471f1925">
</p>

# Wofür das Ganze?

## Vergleich mit Unfallatlas von DESTATIS

Der Unterschied der App zum webbasierten [Unfallatlas](https://unfallatlas.statistikportal.de) von DESTATIS liegt zum einen in der leichten und schnellen Nutzbarkeit auf einem iPhone, iPad oder Mac und zum anderen in zusätzlichen Informationen und Features. Im Wesentlichen gehören dazu die vielfältigen Filtermöglichkeiten sowie die zusätzlichen, über die farbigen Kreise und Text- und Emojisymbole dargestellten Informationen zu den einzelnen Unfällen sowie die Möglichkeit der Lookaround-Ansicht für den Unfallort. Zudem werden nicht nur die Unfälle eines Jahres gleichzeitig angezeigt, sondern die Daten aller in der Datenbank enthaltenen Unfalljahre. Der [Unfallatlas](https://unfallatlas.statistikportal.de) von DESTATIS besticht dafür zum Beispiel durch die Einfärbung der Straßen entsprechend der Unfallhäufigkeit über das gesamte Straßennetz, und das bereits in der Anfangskartenansicht von ganz Deutschland. Zudem kann dort nach Adressen gesucht werden, was in der vorliegenden App noch nicht realisiert ist.

## Anwendungsfälle

Im Wesentlichen sind es zwei Anwendungsfälle: Zum einen Unfallschwerpunkte zu finden, im Detail zu analysieren und mögliche Ursachen zu bestimmen sowie Verbesserungmaßnahmen zu entwickeln. Zum anderen kann über die Filterung ein Gefühl für die Statistik des Unfallgeschehens in Deutschland insgesamt erhalten werden. Dabei ist zu beachten, dass im Unfalldatenatlas nicht alle polizeilich erfassten Unfälle mit Personenschaden enthalten sind, sondern grob über den Daumen ca. 90% [^1]. Es wird angenommen, dass dies einigermaßen gleichverteilt ist und die Statistik nicht wesentlich beeinträchtigt. Nachfolgend einige Beispiele.

### Statistikbeispiele 

Die 1.554.834 in der Datenbank enthalten Unfälle teilen sich wie folgt auf:

- 15.578 (1%) Unfälle mit Getöteten
- 289.961 (19%) Unfälle mit Schwerverletzen
- 1.249.295 (80%) Unfälle mit Leichtverletzen 

Unfälle bei trockenem Straßenzustand sind mit insgesamt 1.159.666 Unfällen (75%) dominant gegenüber Unfällen bei nass/feucht/schlüpigem Straßenzustand (360.507 bzw. 23%) und winterglattem Straßenzustand (34.661 bzw. 2,2%). 

Die meisten Unfälle ereigneten sich bei Tageslicht mit insgesamt 1.179.389 Unfällen (76%). Bei Dunkelheit waren es 292.333 Unfälle (19%) und bei Dämmerung 83.112 Unfälle (5%). Betrachtet man nur die 15.578 Unfälle mit Getöten, so verschiebt sich das Verhältnis etwas in Richtung Dunkelheit mit 4.070 Unfällen (26%) bei Dunkelheit. Bei Dämmerung sind es 833 Unfälle (5%). 

### Beispiele aufälliger Unfallorte

Bei den Auffälligkeiten ist zu berücksichtigen, dass keine Information zur Verkehrsdichte vorliegt. 

#### Autobahnkreuz bei Stuttgart

Am Autobahnkreuz von A81 und A8 in der Nähe von Stuttgart findet man insgesamt 70 Unfälle im Kartenausschnitt, davon sind 33 Unfälle [Fahrunfälle](https://de.wikipedia.org/wiki/Unfalltyp) (symbolisiert durch grüne Kreise), d.h. Unfälle bei denen der Fahrer die Kontrolle über das Fahrzeug verloren hat, weil die Geschwindigkeit nicht entsprechend dem Verlauf, dem Querschnitt, der Neigung oder dem Zustand der Straße gewählt war, oder weil deren Verlauf oder eine Querschnittsänderung zu spät erkannt wurde. Das Ergebnis ist meist ein Abkommen von der Fahrbahn nach rechs oder links. In der erweiteren Ansicht mit den Unfallsymbolen ist dies angezeigt durch die Unfallarten "A8" und "A9". Von den 33 Fahrunfällen sind 30 auf den Zubringerfahrwegen lokalisiert und nur drei auf der Autbahn selbst. Geht man weiter ins Detail so ereigneten sich davon mit insgesamt 26 Unfällen überproportional viele bei nass/fecht/schlüpfrigem Straßenzustand (23 Unfälle mit Symbol 🌧️) bzw. bei winterglattem Straßenzustand (3 Unfälle mit Symbol ❄️).

<p align="center">
<img src="https://github.com/UPetersen/Unfalldatenatlas/assets/10375483/86694da7-1003-455c-823b-91608d5fd50e" width=90% height=90%>
</p>

<p align="center">
<img src="https://github.com/UPetersen/Unfalldatenatlas/assets/10375483/078a0b0f-41f0-4842-bf32-71102afb3866" width=90% height=90%>
</p>

#### Kreisverkehr in Lübeck

Hier handelt es sich um eine sehr große, als Kreisverkehr ausgebildete Kreuzung in Lübeck, vermutlich mit einem sehr hohen Verkehrsaufkommen. Die Zahl der Unfälle im Kartenausschnitt liegt bei 194 Unfällen. Auffällig ist der hohe Anteil (119 bzw. 62%) an Unfällen mit Fahrradfahrern in diesem Kartenausschnitt, auf den sich die nachfolgende Betrachtung bezieht. In der Satellitenansicht mit Lookaroung-Voransicht sieht man, dass es sich um einen sehr komplexen Kreisverkehr mit zwei Fahrbahnen und entsprechenden Zu- und Abfahrten handelt. Radfahrer müssen im Kreisel selbst fahren, wenn sie nicht unmittelbar nach rechts abzweigen wollen. Entsprechend hoch ist der Anteil an Abbiegeunfällen (42 Unfälle, gelbe Kreise) und Einbiegen-/Kreuzenunfällen (47 Unfälle, rote Kreise). Unfälle im Längsverkehr (orangefarbene Kreise) ereigneten sich  13 Mal. Mit 73 Unfällen ist der Zusammenstoß mit einem einbiegenden/kreuzenden Fahrzeug die vorherschende Unfallart.

|![IMG_5077](https://github.com/UPetersen/Unfalldatenatlas/assets/10375483/946f0613-31a1-4924-a259-58f5eaf50b50)|![IMG_5078](https://github.com/UPetersen/Unfalldatenatlas/assets/10375483/b01b7259-48d2-418e-9120-3134e3bbb57d)|![IMG_5079](https://github.com/UPetersen/Unfalldatenatlas/assets/10375483/4b294ca7-25d6-4ab1-8178-00c2e433118a)|
|:-:|:-:|:-:|
|Alle Unfälle|Unfälle mit Fahrradfahrerbeteiligung|Unfälle mit Fahrradfahrerbeteiligung in Satellitenansicht|



#### Schwarzwaldhochstraße südlich von Geroldsau

Südlich von Geroldsau lieg ein etwa 7 km langer Abschnitt der Schwarzwaldhochstraße auf dem insgesamt 71 Unfälle sichtbar sind. Auffällig ist der hohe Anteil von 61 Unfällen mit Kraftrad-Beteiligung (🏍️), auf den sich die folgende Analyse konzentriert, siehe nachfolgende Bilder. Von diesen 61 Unfällen sind 8 Unfälle mit zusätzlicher Pkw-Beteiligung (🚗🏍️), ein Unfall mit zusätzlicher Radfahrerbeteiligung (🏍️🚴) und die überwiegende Mehrheit von 52 Unfällen nur mit Kraftrad-Beteiligung (🏍️). Die Unfallschwere ist insgesamt hoch mit 6 Unfällen mit Getöteten (✟) und 30 Unfällen mit Schwerverletzen (🏥). 

<table>
  <tr>
    <td>
      <img  src="https://github.com/UPetersen/Unfalldatenatlas/assets/10375483/be78e61a-ffed-4389-b4a2-0b73daa27071" >
    </td>
    <td>
      <img src="https://github.com/UPetersen/Unfalldatenatlas/assets/10375483/e80f8d27-73c9-4f2c-a5bb-eae944056fe7" >
    </td>
  </tr>

  <tr>
    <td align="center"> Unfälle mit Kraftradbeteilgung Schwarzwaldhochstraße südlich von Geroldsau </td>
    <td align="center"> Unfälle mit Kraftradbeteilgung Schwarzwaldhochstraße südlich von Geroldsau mit Zusatzinformationen </td>
  </tr>
</table>


Der Anteil der Fahrunfälle (grüne Kreise) ist mit 56 der 61 Unfälle absolut dominant. Die anderen Unfälle verteilen sich auf einen Abbiegeunfall (gelber Kreis), drei Einbiegen/Kreuzen-Unfälle (rote Kreise), die sich an einer Parkplatz Zu-/Abfahrt ereigneten und einen Unfall im Längsverkehr (orangefarbener Kreis, in den Bildern von grünen Kreisen überdeckt und ohne weiteres Filtern oder Zommen nicht sichtbar). Bemerkenswert ist, dass weder schlechte Witterung noch dunkle Beleuchtungsbedingungen zugrunde lagen, denn nur ein Unfall fand bei nass/feucht/schlüpfrigem Staßenzustand statt und einer bei Dunkelheit.

Hinsichtlich der Unfallart ist Abkommen von der Fahrbahn mit 42 Unfällen (Unfallarten A8 und A9) am häufigsten. Darauf folgen 10 Zusammenstöße mit einem entgegenkommenden Fahrzeug (A4), 6 davon mit Pkw-Beteiligung. Bei den anderen 4 Unfällen ist nur eine reine Kraftradbeteiligung registriert, so dass von einer Gegenverkehrskollision von Krafträdern auszugehen ist. Zusammenstöße mit einbiegenden Fahrzeug (A5) ereigneten sich 3 mal an den mit roten Kreisen gekennzeichneten Orten, auch jeweils nur mit Kraftrad-Beteiligung. Dort ist eine Parkplatzzufahrt bzw. -abfahrt. Der Unfall mit dem Radfahrer war ein Zusammenstoß mit einem seitlich in gleiche Richtung fahrenden Fahrzeug (A3). Die restlichen 4 Unfälle sind mit Unfall anderer Art (A0) keiner klaren Unfallart zugeordnet. 

Interessant ist noch die Verteilung der Unfälle über die letzten Jahre, siehe nachfolgende Tabelle. Auffällig ist die große Häufung an Unfällen mit Kraftradbeteiligung in den Corona-Jahren 2020 und 2021. Zum Vergleich sind die in der Datenbank enthaltenen Unfälle in Baden-Würrtemberg und die Unfälle mit Kraftradbeteiligung in Baden-Württemberg mit angegeben. Im Jahresdurchschnitt waren die letztgenannten Unfallzahlen für 2020 und 2021 eher gering, so dass sich die Unfallhäufung auf diesem Abschnitt der Schwarzwaldhochstraße nicht dadurch erklären lässt.

|Jahr |	Unfälle mit Kraftradbeteiligung im Kartenausschnitt	|Unfälle mit Kraftradbeteiligung in Baden-Württemberg	|Unfälle insgesamt in Baden-Württemberg| 
|:-:|:-:|:-:|:-:|
|2016|	6	|5597|33931	|
|2017| 	4	|5691|33553	|
|2018| 	9	|6038|34028	|
|2019| 	4	|5280|32964	|
|2020| 	**19**	|4940|28450	|
|2021| 	**13**	|4347|27017	|
|2022| 	6	|5030|30494	|

Ein Kurvenabschnitt auf dem sich insgesamt 15 Unfälle mit Kraftradbeteiligung ereigneten sei noch besonders betrachtet, siehe nachfolgende Bilder. 14 Unfälle sind Fahrunfälle und ein Unfall ist ein Abbiegunfall bei der Abfahrt zum Parkplatz. In der Lookaround-Ansicht (Bilder von August 2019) sieht man einen sehr guten Straßenzustand. Bewegt man sich entlang der Straße, so findet man eine Geshwindigkeitsbegrenzung auf 50 km/h für diese Kurve und die dahinter liegende Kurve. Nun stammen die Bilder aus dem Jahre 2019 und es könnte sein, dass die Straßenverhältnisse in den anderen Jahren komplett anders waren. Trotzdem liegt insgesamt der Schluss nahe, dass es sich bei diesem Straßenabschnitt um eine schöne Motorradstrecke mit schönen Kurven handelt, die insbesondere von Motorradfahrern häufig gerne schnell durchfahren und dabei immer mal wieder unterschätzt wird.

|![IMG_5077](https://github.com/UPetersen/Unfalldatenatlas/assets/10375483/920ab4aa-3075-4cda-87f1-8c7700e182df)|![IMG_5077](https://github.com/UPetersen/Unfalldatenatlas/assets/10375483/b853fa75-2378-44e7-b5d1-8759ccdf60a8)|![IMG_5077](https://github.com/UPetersen/Unfalldatenatlas/assets/10375483/2cddad57-8c05-4492-a5ca-7046b529c2f2)|
|:-:|:-:|:-:
|Kurve beim Parkplatz Helbingfelsen | Lookaround-Ansicht der Kurve beim Parkplatz Helbingfelsen | Geschwindigkeitsbegrenzung 50 km/h für die Kurve beim Parkplatz Helbingfelsen |

Filtert man in der App auf Fahrunfälle mit Kraftradbeteiligung und sucht wenige Minuten, so findet man an vielen Orten in Deutschland Streckenabschnitte oder einzelne Kurven mit ähnlichen Unfallhäufungen bzw. -mustern. Beispielhaft dafür seien noch die Bundesstraße 308 (Alpenstraße) westlich von Scheidegg (linkes nachfolgendes Bild)  sowie die Bundesstraße 276 zwischen Schotten und Laubach genannt (rechtes Bild). Bemerkenswert an der B276 bei Schotten ist, dass die Unfallzahl in den Jahren 2021 und 2022 mit insgesamt 6 der 83 Unfälle im Kartenausschnit im Vergleich zu den fünf Vorjahren extrem gering ist. Vielleicht hat man dort entsprechende Maßnahmen ergriffen, um die Unfallhäufigkeit zu verringern.

<table>
  <tr>
    <td>
      <img src="https://github.com/UPetersen/Unfalldatenatlas/assets/10375483/6986c33c-9d2e-4065-b71e-ea7bed86b408" title="Dolor sit">
    </td>
    <td>
      <img src="https://github.com/UPetersen/Unfalldatenatlas/assets/10375483/e0e2a38a-7923-4f5d-9e1f-4c2cb0629ccd" title="Dolor sit">
    </td>
  </tr>
  <tr>
    <td align="center"> Unfälle mit Kraftradbeteiligung auf Abschnitt der B308 bei Scheidegg </td>
    <td align="center"> Unfälle mit Kraftradbeteiligung auf Abschnitt der B276 bei Schotten </td>
  </tr>
</table>


Abschließend sei nochmals angemerkt, dass auch bei dieser Analyse zu beachten ist, dass die in der Datenbank enthaltenen Unfälle nicht alle polizeilich registrierten Unfälle mit Personenschaden abbilden und das tatsächliche Unfallgeschen anders sein kann [^1]. Damit kann sich prinzipiell auch die Verteilung unterscheiden. An der insgesamt hohen Unfallzahl auf den betrachteten Straßenabschnitten ändert das jedoch wenig bzw die tatsächliche Zahl an Unfällen mit Personenschaden kann größer sein. 

## Weitere Einschränkungen

Da nur eine begrenzte Menge von Unfällen im Kartenausschnitt angezeigt wird, ist die Verteilung dieser Punkte letztlich willkürlich, solange nicht alle im Kartenausschnitt enthaltenen Unfälle angezeigt werden können. Beim Start der App wird Deutschland in voller Fläche dargestellt, aber nur 400 der 1.554.383 Unfälle angezeigt und entsprechend nur die ersten 400 aus der Datenbank abgefragt, um die Anzeige schnell aktualisieren zu können. Als Konsequenz daraus werden dann meist nur 400 Punkte in einem Bundesland oder einer Ecke Deutschlands angezeigt, wo eine gleichmäßige Verteilung über die Deutschlandkarte doch etwas schöner wäre.

<p align="center">
<img width="400" src="https://github.com/UPetersen/Unfalldatenatlas/assets/10375483/c79be0bc-4a57-43fe-bfca-0e90b7235aa6" >
</p>

Bei Auswahl nach mehreren Kriterien, welche die Unfallzahl nur wenig reduzieren, z.B. Unfälle bei Tageslicht mit Leichtverletzten und Pkw-Beteiligung verlängert sich das Laden der Daten unter Umständen erheblich. Bei mehreren Kriterien ist es grundsätzlich ratsam, das Kriterium, welches die Unfallzahl am meisten reduziert, als Erstes auszuwählen. Also z.B. für Unfälle mit Getöteten bei Tageslicht erst Unfälle mit Getöteten ( 1% der Unfälle) auswählen und danach auf Unfälle bei Tageslicht (76% der Unfälle) einschränken (statt umgekehrt). Eine weitere Empfehlung ist, erst in den Bereich auf der Karte zu zoomen, der von Interesse ist und danach zu filtern. Je kleiner der Kartenausschnitt, umso schneller werden die Daten aus der Datenbank gelesen.

Die Zahl der Unfälle im Kartenausschnitt ist nur korrekt bei nach Norden ausgerichter Karte und in der Standardkartenansicht (nicht Satellitenansicht, kein 3D) und wird deshalb nur bei nach Norden ausgerichtetet Karte mit Standardansicht angzeigt. Wird die Lookaround-Voransicht ein- oder ausgeblendet, so aktualisiert sich die Zahl der Unfälle im Kartenausschnitt nicht. Dazu bitte die Karte z. B. einmal leicht verschieben.

# Datenquelle, Rechtliche Hinweise und Datenschutzerklärung
                        
Die angezeigten Daten stammen vom [Unfallatlas](https://unfallatlas.statistikportal.de) des Statistischen Bundesamt (DESTATIS). In einzelnen Bundesländern sind die Daten nicht für den gesamten Zeitraum verfügbar. Weitere Informationen zur Datengrundlage sind [hier](https://unfallatlas.statistikportal.de) zu finden.
            
Die Nutzung der Daten erfolgt auf Basis der [Datenlizenz Deutschland – Namensnennung – Version 2.0](https://www.govdata.de/dl-de/by-2-0).
            
Es werden keine personenbezogenen Daten gespeichert.

Wenn der Nutzer dem Teilen des Standorts für diese App zustimmt, wird der aktuelle Standort des Anzeigegerätes (iPhone, iPad oder Mac) genutzt, um diesen auf der Karte anzuzeigen und einen schnellen Wechsel zu diesem Ort zu ermöglichen. Der Standort wird nicht in der App gespeichert.
            

# Haftungsausschluss
            
Für die Richtigkeit der angezeigten Informationen wird keinerlei Haftung oder Gewähr übernommen. Bitte rechnen Sie damit, dass die App fehlerhaft sein kann.

# Lizenz

GNU GENERAL PUBLIC LICENSE [Version 3](https://github.com/UPetersen/Unfalldatenatlas/blob/main/LICENSE).
            

[^1]: Im Unfalldatenatlas sind nicht alle polizeilich erfassten Unfälle mit Personenschaden enthalten, sondern grob über den Daumen ca. 90%. Beispielsweise hat DESTATIS für das Jahr 2022 insgesamt 289.672 Unfälle mit Personenschaden registriert, von denen 256.492 im Unfalldatenatlas enthalten sind. Siehe dazu die Erläuterungen zum Unfallatlas auf der [Unfallatlas-Webseit](https://unfallatlas.statistikportal.de).
