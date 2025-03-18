//
//  BluetoothPeripheralsView.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 19.06.2024.
//

import Combine
import SwiftUI

struct BluetoothPeripheralsView: View, Notifiable {
    @Environment(BluetoothPeripherals.self) private var peripherals
    
    @State private var selection: UUID?
    @State private var onlyD110: Bool = false
    @Binding var isPresented: Bool
    
    @State private var rowHovered: UUID? = nil
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 10) {
                Spacer()
                ProgressView().progressViewStyle(.circular)
                Text("Searching ...")
                Spacer()
            }.scenePadding(Edge.Set(arrayLiteral: [.horizontal, .top]))
            
            List(onlyD110 ? peripherals.printersBasedOnName : peripherals.peripherals,
                 id: \.identifier,
                 selection: $selection) { peripheral in
                HStack {
                    Text(peripheral.name)
                    Spacer()
                }.background(rowHovered == peripheral.identifier ? Color.accentColor : .clear).onHover(perform: { hovering in
                    withAnimation {
                        rowHovered = hovering ? peripheral.identifier : nil
                    }
                })
            }.frame(height: 300.0).onChange(of: selection) { oldValue, newValue in
                guard oldValue != newValue else { return }
                guard let value = newValue else { return }
                isPresented = false
                notifyUI(name: Notification.Name.App.selectedPeripheral, userInfo: [String : UUID] (dictionaryLiteral: (Notification.Keys.value, value)))
            }
            .padding(.all)
            
            Toggle("Filter D110 named devices", isOn: $onlyD110)
                .toggleStyle(SwitchToggleStyle(tint: .accentColor)).padding(.horizontal).padding(.bottom)
        }.onAppear() {
            peripherals.removeAll()
            selection = nil
            notifyUI(name: Notification.Name.App.startPopulatingPeripherals)
            
        }.onDisappear() {
            notifyUI(name: Notification.Name.App.stopPopulatingPeripherals)
        }
    }
}

struct BluetoothPeripheralsViewPreviews: PreviewProvider {

    static var previews: some View {
        BluetoothPeripheralsView(isPresented: .constant(true)).environmentObject({ () -> BluetoothPeripherals in
            let envObj = BluetoothPeripherals()
                    envObj.add(peripheral: BluetoothPeripheral(testing: "1st peripheral"))
                    envObj.add(peripheral: BluetoothPeripheral(testing: "2md peripheral"))
                    envObj.add(peripheral: BluetoothPeripheral(testing: "3rd peripheral"))
                    envObj.add(peripheral: BluetoothPeripheral(testing: "4th peripheral"))

                    return envObj
                }() )
    }
}

#Preview {
    BluetoothPeripheralsViewPreviews.previews
}
