//
//  Tariffs.swift
//  ChargepriceKit
//
//  Created by Yannick Heinrich on 02.04.21.
//

import Foundation

/// :nodoc:
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

// MARK: - Public

/// The `Tarrif` entity
public struct Tariff {

    /// The identifier of the `Tarrif`
    public let id: String

    /// Name of the charge card provider
    public let provider: String

    /// Name of the tariff
    public let name: String

    /// If true, tariff is only available for customers of a provider (e.g. electricity provider for the home).
    public let isProviderCustomerOnly: Bool

    /// This tariff can be used without registration
    public let isDirectPayment: Bool

    // GoingElectric charge card ID
    public let chargeCardID: String?

    /// :nodoc:
    init(from: ResourceObject<TariffAttributes, NoData>) {
        self.id = from.id
        self.provider = from.attributes.provider
        self.name = from.attributes.name
        self.isProviderCustomerOnly = from.attributes.isProviderCustomerOnly
        self.isDirectPayment = from.attributes.isDirectPayment
        self.chargeCardID = from.attributes.chargeCardID
    }
}
