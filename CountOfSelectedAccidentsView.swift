//
//  CountOfSelectedAccidentsView.swift
//  Unfalldatenatlas
//
//  Created by Uwe Petersen on 09.10.23.
//

import SwiftUI

fileprivate let formatter: NumberFormatter =  {() -> NumberFormatter in
    let numberFormatter = NumberFormatter()
    numberFormatter.usesSignificantDigits = true
    numberFormatter.maximumSignificantDigits = 2
    numberFormatter.roundingMode = .halfUp
    numberFormatter.zeroSymbol = "0"
    return numberFormatter
}()

/// Displays count of selected accidents or a ProgressView while the count is still being fetched.
struct CountOfSelectedAccidentsView: View {
    
    var countOfSelectedAccidents: Int
    var isFetchingCountOfSelectedAccidents: Bool
    let countOfAllAccidents = Double(ViewModel.countOfAllAccidents)
    
    var body: some View {
        if isFetchingCountOfSelectedAccidents {
            ProgressView()
        } else {
            Text("\(countOfSelectedAccidents) Unfälle\(percentage())")
        }
    }
    
    func percentage() -> String {
        if countOfAllAccidents > 1 { // Never divide by zero
            let percentage = Double(countOfSelectedAccidents) * 100.0 / countOfAllAccidents
            if let text = formatter.string(from: NSNumber(value: percentage)) {
                return " (\(text) %)"
            }
        }
        return ""
    }
}

#Preview {
//    CountOfSelectedAccidentsView(countOfSelectedAccidents: Int(15.54834), isFetchingCountOfSelectedAccidents: false)
    CountOfSelectedAccidentsView(countOfSelectedAccidents: Int(1), isFetchingCountOfSelectedAccidents: false)
//    CountOfSelectedAccidentsView(countOfSelectedAccidents: 1554834, isFetchingCountOfSelectedAccidents: false)
}
