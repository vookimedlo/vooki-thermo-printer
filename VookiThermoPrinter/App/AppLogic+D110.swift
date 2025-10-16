import Foundation

extension AppLogic: AppLogicPrinting {
    @PrinterActor
    func executePrintCommands() async throws {
        let data = await preparePrintData()
        guard !data.isEmpty else { return }
        
        try await SendAndWaitAsync.waitOnBoolResult(name: .App.setLabelDensity) {
            try await self.printer?.setLabelDensity(density: 1)
        }
        try await SendAndWaitAsync.waitOnBoolResult(name: .App.startPrint) {
            try await self.printer?.startPrint()
        }
        try await SendAndWaitAsync.waitOnBoolResult(name: .App.startPagePrint) {
            try await self.printer?.startPagePrint()
        }
        try await SendAndWaitAsync.waitOnBoolResult(name: .App.setDimension) {
            try await self.printer?.setDimension(width: UInt16(self.appRef.paperEAN.ean.printableSizeInPixels(dpi: self.dpi).width),
                                                 height: UInt16(self.appRef.paperEAN.ean.printableSizeInPixels(dpi: self.dpi).height))
        }
        try await SendAndWaitAsync.waitOnBoolResult(name: .App.setLabelDensity) {
            try await self.printer?.setLabelDensity(density: 1)
        }
        
        let max = data.count
        var currentStep = 1
        for packet in data {
            try printer?.setPrinterData(data: packet)
            notifyUI(name: .App.UI.printSendingProgress,
                     userInfo: [String : Sendable](dictionaryLiteral: (Notification.Keys.value, currentStep != max ? Double(currentStep) / Double(max) * 100.0 : 100.0)))
            currentStep += 1
            try? await Task.sleep(for: .milliseconds(50),
                                  tolerance: .milliseconds(25))
        }
        
        try await SendAndWaitAsync.waitOnBoolResult(name: .App.endPagePrint) {
            try await self.printer?.endPagePrint()
        }
        
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
