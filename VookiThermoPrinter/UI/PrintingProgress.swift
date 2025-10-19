//
//  PrintingProgress.swift
//  VookiThermoPrinter
//
//  Created by Michal Duda on 27.06.2024.
//

import SwiftUI

struct PrintingProgress: View {

    @State private var sendingProgress: Double = 0
    @State private var printingProgress: Double = 0


    var body: some View {
        VStack {
            Spacer()
            
            ProgressView(value: sendingProgress, total: 100,
                         label: {
                Text("Seding data ...")
                    .padding(.bottom, 4)
            }, currentValueLabel: {
                Text("\(Int(sendingProgress))%")
                    .padding(.top, 4)
            }
            ).progressViewStyle(.linear)
                .onReceive(NotificationCenter.default.publisher(for: .App.UI.printSendingProgress)) { notification in
                    let value = notification.userInfo?[Notification.Keys.value] as! Double
                    sendingProgress = value
                }
            
            ProgressView(value: printingProgress, total: 100,
                         label: {
                Text("Printing ...")
                    .padding(.bottom, 4)
            }, currentValueLabel: {
                Text("\(Int(printingProgress))%")
                    .padding(.top, 4)
            }
            ).progressViewStyle(.linear).padding(.top)
                .onReceive(NotificationCenter.default.publisher(for: .App.UI.printPrintingProgress)) { notification in
                    let value = notification.userInfo?[Notification.Keys.value] as! UInt8
                    printingProgress = Double(value)
                }
            
            Spacer()
        }.padding()

    }
}

#Preview {
    PrintingProgress()
}
