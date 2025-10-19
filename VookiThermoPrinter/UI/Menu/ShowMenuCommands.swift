/****************************************************************************
VookiThermoPrinter - A lightweight macOS tool for printing to Niimbot label printers.
- https://github.com/vookimedlo/vooki-thermo-printer

  SPDX-FileCopyrightText: 2024 Michal Duda <github@vookimedlo.cz>
  SPDX-License-Identifier: GPL-3.0-or-later
  SPDX-FileType: SOURCE

****************************************************************************/

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

