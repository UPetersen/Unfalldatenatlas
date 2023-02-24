//
//  InfoView.swift
//  Unfalldatenatlas
//
//  Created by Uwe Petersen on 21.02.23.
//

import SwiftUI

struct InfoView: View {
    var body: some View {
        Text(
"""
**Bedienung**

Information zu Bedienung werden zukünftig hier angezeigt.

Bitte beachten, dass maximal 300 Unfälle im Kartenausschnitt angezeigt werden. Um alle Unfälle in einem Kartenausschnitt zu sehen, muss daher ggf. weiter hineingezoomt werden.

**Datenquelle**

Die angezeigten Daten stammen von Destatis. Es handelt sich um polizeilich registrierte Straßenverkehrsunfälle auf öffentlichen Wegen und Plätzen der Jahre 2016 bis 2021, bei denen Personen getötet oder verletzt wurden. Näheres siehe [DESTATIS](https://unfallatlas.statistikportal.de/_info2022.html). In einzelenen Bundesländern sind die Daten nicht für den gesamten Zeitraum verfügbar.

**Rechtliche Hinweise**

Rechtliche Hinweise zu genutzter Open Source Software sowie zu den verwendeten Daten werden zukünftig hier angezeigt.
"""
        )
        .padding(.horizontal)
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView()
    }
}
