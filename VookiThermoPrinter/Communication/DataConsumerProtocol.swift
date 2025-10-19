//
//  DataConsumerProtocol.swift
//  VookiThermoPrinter
//
//  Created by Michal Duda on 03.06.2024.
//

import Foundation

public protocol DataConsumer: AnyObject {
    func consumeData(data: Data)
}
