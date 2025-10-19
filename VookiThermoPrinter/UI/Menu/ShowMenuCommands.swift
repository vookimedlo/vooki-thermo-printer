//
//  ViewMenuCommands.swift
//  VookiThermoPrinter
//
//  Created by Michal Duda on 06.08.2024.
//

import SwiftUI

struct ShowMenuCommands: Commands, StaticNotifiable {
    @Bindable var uiSettingsProperties: UISettingsProperties

    var body: some Commands {
        CommandMenu("Show") {
            Self.marginGuidelinesMenu(uiSettingsProperties: uiSettingsProperties)
        }
    }

    @ViewBuilder
    static func marginGuidelinesMenu(@Bindable uiSettingsProperties: UISettingsProperties) -> some View {
        Menu(content: {
            Toggle(isOn: $uiSettingsProperties.showHorizontalMarginGuideline) {
                Text("Horizontal")
            }
            Toggle(isOn: $uiSettingsProperties.showVerticalMarginGuideline) {
                Text("Vertical")
            }
        }, label: {
            SwiftUI.Image(systemName: "line.diagonal")
                .symbolRenderingMode(.palette)
                .fontWeight(.regular)
            Text("Margin guidelines ...")
        })
    }
}
