//
//  CountOfSelectedAccidentsView.swift
//  Unfalldatenatlas
//
//  Created by Uwe Petersen on 09.10.23.
//

import SwiftUI

/// Displays count of selected accidents or a ProgressView while the count is still being fetched.
struct CountOfSelectedAccidentsView: View {
    
    var countOfSelectedAccidents: Int
    var isFetchingCountOfSelectedAccidents: Bool
    
    var body: some View {
        if isFetchingCountOfSelectedAccidents {
            ProgressView()
        } else {
            Text("\(countOfSelectedAccidents)")
        }
    }
}

#Preview {
    CountOfSelectedAccidentsView(countOfSelectedAccidents: 1554834, isFetchingCountOfSelectedAccidents: false)
}
