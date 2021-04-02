//
//  Tariffs.swift
//  ChargepriceKit
//
//  Created by Yannick Heinrich on 02.04.21.
//

import Foundation

struct TariffAttributes: ResourceAttributes {
    static let typeName: String = "tariff"

    let provider: String
    let name: String
    let isProviderCustomerOnly: Bool
    let isDirectPayment: Bool
    let chargeCardID: String?

    enum CodingKeys: String, CodingKey {
        case provider
        case name
        case isProviderCustomerOnly = "provider_customer_only"
        case isDirectPayment = "is_direct_payment"
        case chargeCardID = "charge_card_id"
    }
}


public struct Tariff {
    public let id: String
    public let provider: String
    public let name: String
    public let isProviderCustomerOnly: Bool
    public let isDirectPayment: Bool
    public let chargeCardID: String?

    init(from: ResourceObject<TariffAttributes, NoData>) {
        self.id = from.id
        self.provider = from.attributes.provider
        self.name = from.attributes.name
        self.isProviderCustomerOnly = from.attributes.isProviderCustomerOnly
        self.isDirectPayment = from.attributes.isDirectPayment
        self.chargeCardID = from.attributes.chargeCardID
    }
}
