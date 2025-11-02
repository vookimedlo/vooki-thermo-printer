/****************************************************************************
VookiThermoPrinter - A lightweight macOS tool for printing to Niimbot label printers.
- https://github.com/vookimedlo/vooki-thermo-printer

  SPDX-FileCopyrightText: 2025 Michal Duda <github@vookimedlo.cz>
  SPDX-License-Identifier: GPL-3.0-or-later
  SPDX-FileType: SOURCE

****************************************************************************/

import Foundation

extension AppLogic: AppLogicPrinting {
    @PrinterActor
    func executePrintCommands() async throws {
        let data = await preparePrintData()
        guard !data.isEmpty else { return }
        
        try await SendAndWaitAsync.waitOnBoolResult(name: .App.setLabelDensity) {
            try await self.printer?.setLabelDensity(density: 1)
        }
        try await SendAndWaitAsync.waitOnBoolResult(name: .App.setLabelType) {
            try await self.printer?.setLabelType(type: self.appRef.paperEAN.ean.labelType)
        }
        try await SendAndWaitAsync.waitOnBoolResult(name: .App.cancelPrint) {
            try await self.printer?.cancelPrint()
        }
        try await SendAndWaitAsync.waitOnBoolResult(name: .App.startPrint) {
            try await self.printer?.startPrint(pagesCount: 1)
        }
        try await SendAndWaitAsync.waitOnBoolResult(name: .App.startPagePrint) {
            try await self.printer?.startPagePrint()
        }
        try await SendAndWaitAsync.waitOnBoolResult(name: .App.setDimension) {
            try await self.printer?.setDimension(width: UInt16(self.appRef.paperEAN.ean.printableSizeInPixels(dpi: self.appDetails.dpi).width),
                                                 height: UInt16(self.appRef.paperEAN.ean.printableSizeInPixels(dpi: self.appDetails.dpi).height),
                                                 copiesCount: 1)
        }
        try await SendAndWaitAsync.waitOnBoolResult(name: .App.setLabelDensity) {
            try await self.printer?.setLabelDensity(density: 1)
        }
        
        let max = data.count
        var currentStep: UInt16 = 1
        for packet in data {
            Self.logger.error("Image data packet \(currentStep)/\(max)")

            try printer?.setPrinterData(data: packet)
            notifyUI(name: .App.UI.printSendingProgress,
                     userInfo: [String : Sendable](dictionaryLiteral: (Notification.Keys.value, currentStep != max ? Double(currentStep) / Double(max) * 100.0 : 100.0)))
            try? await Task.sleep(for: .milliseconds(30),
                                  tolerance: .milliseconds(25))

            currentStep += 1
        }
        
        try await SendAndWaitAsync.waitOnBoolResult(name: .App.endPagePrint) {
            try await self.printer?.endPagePrint()
        }
        
        // It seems that the status is correct after 5th status packet with 50ms gap when the second page is sent.
        // So just wait 400ms.
        try await Task.sleep(for: .milliseconds(400))
        
        try await SendAndWaitAsync.waitOnBoolResult(name: .App.printFinished,
                                                    timeout: .seconds(10)) {
            while !Task.isCancelled {
                try await self.printer?.getPrintStatus()
                try await Task.sleep(for: .milliseconds(50))
            }
        }
        
        try await SendAndWaitAsync.waitOnBoolResult(name: .App.endPrint) {
            try await self.printer?.endPrint()
        }
        
        try printer?.getRFIDData()
    }
}
