//
//  LabelMenuCommands.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 13.08.2024.
//

import SwiftUI


struct LabelMenuCommands: Commands, StaticNotifiable {
    @State var selection: Int = 1
    @Bindable var paperEAN: ObservablePaperEAN
    @Bindable var textProperties: TextProperties
    @Bindable var printerAvailability: PrinterAvailability

    private static let types: [String: PaperEAN] = {
        var dict = [String: PaperEAN]()
        for ean in PaperEAN.allCases {
            dict[ean.description] = ean
        }
        return dict
    }()
    
    private static let keys = Self.types.keys.sorted()

    private struct ToggleMenu: View, StaticNotifiable {
        @Binding var selection: Int
        @State private var isOn: Bool
        let index: Int
        let text: String
        
        @Bindable var paperEAN: ObservablePaperEAN
        
        init(text: String, index: Int, selection: Binding<Int>, paperEAN: Bindable<ObservablePaperEAN>) {
            self.text = text
            self.index = index
            self._selection = selection
            self.isOn = index == selection.wrappedValue
            self._paperEAN = paperEAN
        }

        var body: some View {
            Toggle(isOn: $isOn) {
                Text(text)
            }
            .onChange(of: isOn, initial: false) { oldValue, newValue in
                if oldValue != newValue {
                    if newValue {
                        selection = self.index
                        paperEAN.ean = types[text]!
                        Self.notifyUI(name: .App.textPropertiesUpdated)
                    }
                }
            }
            .onChange(of: selection, initial: false) { oldValue, newValue in
                if oldValue != newValue {
                    self.isOn = index == $selection.wrappedValue
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .App.paperChanged)) { notification  in
                let ean = notification.userInfo?[Notification.Keys.value] as! PaperEAN
                let foundIndex = LabelMenuCommands.keys.firstIndex(of: ean.description) ?? 0
                if index == foundIndex {
                    selection = foundIndex
                }
            }
        }
    }
    
    var body: some Commands {
        CommandMenu("Label") {
            Button(action: {
                withAnimation {
                    textProperties.properties = [TextProperty()]
                }
                Self.notifyUI(name: .App.textPropertiesUpdated)
            }) {
                Text("Clear")
            }

            Menu(content: {
                Button(action: {
                    Self.notifyUI(name: .App.paperDetect)
                }) {
                    Text("Autodetect")
                }.disabled(!printerAvailability.isConnected)
                
                Divider()
                
                if ($selection.wrappedValue >= 0) {
                    ForEach(0..<Self.keys.count, id: \.self) { index in
                        ToggleMenu(text: Self.keys[index],
                                   index: index,
                                   selection: $selection,
                                   paperEAN: $paperEAN)
                    }
                }
            }, label: {
                Text("Type ...")
            })
        }
    }
}
