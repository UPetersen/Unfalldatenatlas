//
//  InfoView.swift
//  Unfalldatenatlas
//
//  Created by Uwe Petersen on 21.02.23.
//

import SwiftUI

struct InfoView: View {
    
    @Environment(\.dismiss) var dismiss

    var accidentsFetchLimit: Int
    
    var body: some View {
        ScrollView() {
            VStack(alignment: .leading) {
                
                Text("""
            **Unfalldatenatlas**
            
            Diese App zeigt mehr als 1,8 Millionen polizeilich registrierte Unfälle mit getöteten oder verletzen Personen der Jahre 2016 bis 2023 auf einer Deutschlandkarte an. Zu den einzelnen Unfällen können verschiedene Attribute wie z.B. Unfallart und -typ oder Unfallbeteiligte (Pkw, Fahrrad, Fußgänger etc.) eingeblendet werden. Zudem können die angezeigten Unfälle nach vielen Attributen gefiltert werden. So lassen sich die angzeigten Unfälle z.B. auf alle Fahrunfälle mit Getöteten und Beteiligung von Krafträdern bei feuchter/nasser/schlüpfriger Fahrbahn einschränken.
            
            **Anzeige der Unfallorte**
            
            Die einzelnen Unfälle werden auf der Karte am Unfallort durch Kreise angezeigt, die entsprechend [der Farbskala für Unfalltypen](https://de.wikipedia.org/wiki/Unfalltyp) eingefärbt sind:
            """)
                
                HStack {
                    VStack(alignment: .leading) {
//                        HStack {
//                            Image(systemName: "smallcircle.filled.circle.fill").foregroundStyle(.green)
//                            Text("Fahrunfall")
//                        }.padding(.vertical, 1)
//                        HStack {
//                            Image(systemName: "smallcircle.filled.circle.fill").foregroundStyle(.yellow)
//                            Text("Abbiegeunfall")
//                        }.padding(.vertical, 1)
//                        HStack {
//                            Image(systemName: "smallcircle.filled.circle.fill").foregroundStyle(.red)
//                            Text("Einbiegen-/Kreuzenunfall")
//                        }.padding(.vertical, 1)
//                        HStack {
//                            Image(systemName: "smallcircle.filled.circle.fill").foregroundStyle(.white)
//                            Text("Überschreitenunfall")
//                        }.padding(.vertical, 1)
//                        HStack {
//                            Image(systemName: "smallcircle.filled.circle.fill").foregroundStyle(.blue)
//                            Text("Unfall durch ruhenden Verkehr")
//                        }.padding(.vertical, 1)
//                        HStack {
//                            Image(systemName: "smallcircle.filled.circle.fill").foregroundStyle(.orange)
//                            Text("Unfall im Längsverkehr")
//                        }.padding(.vertical, 1)
//                        HStack {
//                            Image(systemName: "smallcircle.filled.circle.fill").foregroundStyle(.black)
//                            Text("Sonstiger Unfall")
//                        }.padding(.vertical, 1)
                        HStack {
                            Image(systemName: "circle.fill").foregroundStyle(.green)
                            Text("Fahrunfall")
                        }.padding(.vertical, 1)
                        HStack {
                            Image(systemName: "circle.fill").foregroundStyle(.yellow)
                            Text("Abbiegeunfall")
                        }.padding(.vertical, 1)
                        HStack {
                            Image(systemName: "circle.fill").foregroundStyle(.red)
                            Text("Einbiegen-/Kreuzenunfall")
                        }.padding(.vertical, 1)
                        HStack {
                            Image(systemName: "circle.fill").foregroundStyle(.white)
                            Text("Überschreitenunfall")
                        }.padding(.vertical, 1)
                        HStack {
                            Image(systemName: "circle.fill").foregroundStyle(.blue)
                            Text("Unfall durch ruhenden Verkehr")
                        }.padding(.vertical, 1)
                        HStack {
                            Image(systemName: "circle.fill").foregroundStyle(.orange)
                            Text("Unfall im Längsverkehr")
                        }.padding(.vertical, 1)
                        HStack {
                            Image(systemName: "circle.fill").foregroundStyle(.black)
                            Text("Sonstiger Unfall")
                        }.padding(.vertical, 1)
                    }
                    .padding(.leading, 10)
                    .padding()
                    
                    Spacer()
                }
                .background(.quaternary)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
                Text("""
            
            Bitte beachten Sie, dass maximal \(accidentsFetchLimit) Unfälle im Kartenausschnitt angezeigt werden. Um alle Unfälle in einem Kartenausschnitt zu sehen, muss daher ggf. weiter hineingezoomt werden. 
            
            **Anzeige von Unfalldetails \(Image(systemName: "ellipsis.rectangle"))**
            
            Über den Button \(Image(systemName: "ellipsis.rectangle")) kann auf eine detaillierte Darstellung umgeschaltet werden, bei der über Text und Emojie-Symbole Zusatzinformationen zu jedem einzelnen Unfall angezeigt werden, z.B. "21h,Mi,Jun16🚗🚴🌝🌧️🏥A5". Folgende Information werden dabei in der dargestellten Reihenfolge hintereinander angezeigt:
            
            Unfallzeit:
            Stunde des Tages, Wochentag, Monat und Jahr, z.B. "21h,Mi,Jun16" für einen Unfall zwischen 21 und 22 Uhr, an einem Mittwoch im Juni 2016. Das genaue Datum und die genaue Uhrzeit sind aus Datenschutzgründen nicht verfügbar.
            
            Unfallbeteiligte:
            🚗 für Unfälle, an denen mindestens ein Pkw beteiligt war.
            🏍️ für Unfälle, an denen mindestens ein Kraftrad (z.B. Mofa, Motorrad/-roller) beteiligt war.
            🚴 für Unfälle, an denen mindestens ein Fahrrad beteiligt war.
            🚶‍♂️ für Unfälle, an denen mindestens ein Fußgänger(in) beteiligt war.
            🚚 für Unfälle, an denen mindestens ein Lastkraftwagen mit Normalaufbau und einem Gesamtgewicht über 3,5 t, ein Lastkraftwagen mit Tankauflage bzw. Spezialaufbau,eine Sattelzugmaschine oder eine andere Zugmaschine beteiligt war (diese Kategorie ist in den Jahren 2016 und 2017 in der nachfolgenden Kategorie enthalten)
            🚚/🚌/🚃 bzw. 🚌/🚃 (ab 2018) für Unfälle an denen mindestens ein oben nicht genanntes Verkehrsmittel beteiligt war, wie z.B. ein Bus oder eine Straßenbahn. Für die Jahre 2016 und 2017 einschließlich Unfall mit Güterkraftfahrzeug, ab 2018 ohne Güterkraftfahrzeuge.
                        
            Lichtverhältnisse:
            🌛 für Unfälle bei Dämmerung und 🌝 für Unfälle bei Dunkelheit. Wird nichts angezeigt war der Unfall bei Tageslicht.
            
            Straßenzustand:
            🌧️ für nass/feucht/schlüpfrigen Straßenzustand, ❄️ für winterglatten Straßenzustand. Wird nichts angezeigt war der Unfall bei trockenem Straßenzustand.
            
            Verletzungsschwere:
            ✟ für Unfälle mit Getöteten, d.h. Personen, die innerhalb von 30 Tagen an den Unfallfolgen starben.
            🏥 für Unfälle mit Schwerverletzten, d.h. Personen, die unmittelbar zur stationären Behandlung (mindestens 24 Stunden) in einem Krankenhaus aufgenommen wurden.
            🩹 für Unfälle mit Leichtverletzten, d.h. alle übrigen Verletzten.
            
            [Unfallart](https://www.destatis.de/DE/Themen/Gesellschaft-Umwelt/Verkehrsunfaelle/Methoden/_inhalt.html#sprg371798):
            A1 für Zusammenstoß mit anfahrendem/anhaltendem/ruhendem Fahrzeug.
            A2 für Zusammenstoß mit vorausfahrendem/wartendem Fahrzeug.
            A3 für Zusammenstoß mit seitlich in gleicher Richtung fahrendem Fahrzeug.
            A4 für Zusammenstoß mit entgegenkommendem Fahrzeug.
            A5 für Zusammenstoß mit einbiegendem/kreuzendem Fahrzeug.
            A6 für Zusammenstoß zwischen Fahrzeug und Fußgänger.
            A7 für Aufprall auf Fahrbahnhindernis.
            A8 für Abkommen von der Fahrbahn nach rechts.
            A9 für Abkommen von der Fahrbahn nach links.
            A0 für Unfälle anderer Art.
            
            **Datenauswahl bzw. -filterung \(Image(systemName: "line.3.horizontal.decrease.circle"))**
            
            Über den Button \(Image(systemName: "line.3.horizontal.decrease.circle")) kann die Anzeige vielfältig auf bestimmte Unfälle eingegrenzt werden. Neben den Daten der Detailanzeige (Unfalljahr, Unfallbeteiligte, Lichtverhältnisse, Straßenzustand, Verletzungsschwere und Unfallart) lassen sich dabei auch der Wochentag, der Monat sowie das Bundesland auswählen bzw. eingrenzen. Alle diese Kategorien lassen sich beliebig verknüpfen, z.B. Unfälle mit Getöteten und Beteiligung von Pkw- und Radfahrern bei Nacht oder Fahrunfälle mit Beteiligung von Krafträdern ohne Beteiligung von Pkw et Cetera. Mehrfachauswahlen innerhalb einer Kategorie, z.B. Unfälle an Samstagen oder Sonntagen sind noch nicht implementiert.
            
            **Lookaround-Ansicht \(Image(systemName: "binoculars"))**

            Über den Button \(Image(systemName: "binoculars")) kann eine Lookaround-Ansicht des Unfallortes eingeblendet werden. Nach Zuschalten der Ansicht einfach das Kreissymbol eines Unfalles anklicken.
            
            **Datenquelle, Rechtliche Hinweise und Datenschutz**
                        
            Die angezeigten Daten stammen vom [Unfalldatenatlas](https://unfallatlas.statistikportal.de) des Statistischen Bundesamt (DESTATIS). In einzelnen Bundesländern sind die Daten nicht für den gesamten Zeitraum verfügbar. Weitere Informationen zur Datengrundlage sind auf der [Webseite des Unfallatlas](https://unfallatlas.statistikportal.de) zu finden. Eine Erörterung dazu findet sich [hier](https://github.com/UPetersen/Unfalldatenatlas#datenquelle-und-inhalte).
            
            Die Nutzung der Daten erfolgt auf Basis der [Datenlizenz Deutschland – Namensnennung – Version 2.0](https://www.govdata.de/dl-de/by-2-0).
            
            Die Daten sind im Download der App im Originalformat enthalten und werden beim ersten Start der App einmalig in eine lokale Datenbank umgespeichert. Dies kann mehrere Minuten dauern.
            
            Es werden keine personenbezogenen Daten gespeichert.
            
            Wenn dem Teilen des Standorts für diese App zugestimmt wurde, wird der aktuelle Standort des Anzeigegerätes (iPhone, iPad oder Mac) genutzt, um diesen auf der Karte anzuzeigen und einen schnellen Wechsel zu diesem Ort zu ermöglichen. Der Standort wird nicht in der App gespeichert.

            
            **Einschränkungen**
            
            Diese App ist ein Hobbyprojekt, [Open Source](https://github.com/UPetersen/Unfalldatenatlas) und kostenlos verfügbar. Nicht alles ist perfekt, manchmal ruckelt es. Bitte berücksichtigen Sie das bei eventuellen Bewertungen.
            
            Bitte beachten Sie, dass maximal \(accidentsFetchLimit) Unfallorte im Kartenausschnitt angezeigt werden. Um alle Unfallorte in einem Kartenausschnitt zu sehen, muss daher ggf. weiter hineingezoomt werden. 
                        
            Die Auswahl der maximal \(accidentsFetchLimit) angezeigten Unfallorte erfolgt zufällig. Aus Performancgründen wird dabei zunächst nur das jüngste Unfalljahr abgefragt. Sollten darin weniger als \(accidentsFetchLimit) Unfälle enthalten sein, werden sukzessive die nachfolgenden Unfalljahre mit einbezogen, bis \(accidentsFetchLimit) Unfälle oder weniger (dann über alle Unfalljahre) für den Kartenausschnitt vorliegen. 
                        
            Die Bestimmung der Gesamtzahl der im Kartenausschnitt vorhandenen Unfälle kann etwas länger dauern, als das Laden der maximal \(accidentsFetchLimit) in der Karte angezeigten Unfallorte, insbesondere bei vielen Filterbedingungen. Dies liegt daran, dass die komplette Datenbank abgefragt werden muss und nicht nur die ersten \(accidentsFetchLimit) Unfälle, welche den Filterbedingungen für den Kartenausschnitt genügen.

            Die Zahl der Unfälle im Kartenausschnitt ist nur korrekt bei nach Norden ausgerichter Karte und in der Standardkartenansicht (nicht Satellitenansicht, kein 3D) und wird deshalb auch nur bei nach Norden ausgerichtetet Karte mit Standardansicht angzeigt. Wird die Lookaround-Voransicht über den Button \(Image(systemName: "binoculars")) ein- oder ausgeblendet, so aktualisiert sich die Zahl der Unfälle im Kartenausschnitt nicht. Dazu bitte die Karte z. B. einmal leicht verschieben.
            
            **Haftungsausschluss**
            
            Für die Richtigkeit der angezeigten Informationen wiird keinerlei Haftung oder Gewähr übernommen. Bitte rechnen Sie damit dass die App und die angzeigten Informationen fehlerhaft sein können.
            
            """)
            }
            .padding(.horizontal)
        }
        
        .safeAreaInset(edge: .top) {
            HStack {
                Button("Fertig", action: { dismiss() }).hidden()
                    .padding(.horizontal)
                Spacer()
                Text("Bedienung und Hinweise")
                    .font(Font.title3)
                Spacer()
                Button("Fertig", action: { dismiss() })
                    .padding(.horizontal)
            }
            .padding()
            .background(Color(.systemBackground))
        }

//        .navigationTitle("Bedienung und Hinweise")
    }
}

//struct InfoView_Previews: PreviewProvider {
//    static var previews: some View {
//        InfoView(accidentsFetchLimit: 500)
//    }
//}
