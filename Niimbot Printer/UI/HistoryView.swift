//
//  HistoryView.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 13.06.2024.
//

import SwiftUI

struct HistoryView: View {
    var body: some View {
        VStack {
            Text("History View")
            TextTabView()
        }.navigationTitle("History")
    }
}

#Preview {
    HistoryView()
}
