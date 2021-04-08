//
//  Vehicule.swift
//  ChargepriceKit-iOS
//
//  Created by Yannick Heinrich on 17.03.21.
//

import Foundation

/// The different kind of available plugs
public enum Plug: String, Decodable, Equatable, Hashable {
    /// CCS type
    case ccs = "ccs"
    /// Telsa CCS type
    case teslaCCS = "tesla_ccs"
    /// CHADemo type
    case chaDemo = "chademo"
    /// Schuko type
    case schuko = "schuko"
    /// Tesla SUC type
    case teslaSUC = "tesla_suc"
    /// Type1
    case type1 = "type1"
    /// Type2
    case type2 = "type2"
    /// Type3
    case type3 = "type3"
}

/// :nodoc:
struct VehiculeAttributes: Decodable, ResourceAttributes {
    static var typeName: String = "car"

    private enum CodingKeys: String, CodingKey {
        case name
        case brand
        case chargePorts = "dc_charge_ports"
    }

   let name: String
   let brand: String
   let chargePorts: [Plug]
}

/// :nodoc:
struct ManufacturerAttributes: ResourceAttributes {
    /// :nodoc:
    static var typeName: String { "manufacturer" }
}

// MARK: - Public object

/// A vehicule entity
public struct Vehicule {

    /// The identifier of the vehicule
    public let id: String

    /// The name of the vehidule
    public let name: String

    /// The brand of the vehidule
    public let brand: String

    /// Available chargeports. See `Plug` for possible values
    public let chargePorts: [Plug]

    /// The identifier of the manufacturer
    public let manufacturerID: String

    /// :nodoc:
    /// - Parameter data: <#data description#>
    init(data: ResourceObject<VehiculeAttributes, JSONSpecRelationShip<ManufacturerAttributes>>) {
        self.id = data.id
        self.name = data.attributes.name
        self.brand = data.attributes.brand
        self.chargePorts = data.attributes.chargePorts
        self.manufacturerID = data.relationships!.id
    }
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension Vehicule: Identifiable { }
