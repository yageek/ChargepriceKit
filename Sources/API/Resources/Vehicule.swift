//
//  Vehicule.swift
//  ChargepriceKit-iOS
//
//  Created by Yannick Heinrich on 17.03.21.
//

import Foundation

public enum Plug: String, Decodable, Equatable, Hashable {
    case ccs = "ccs"
    case teslaCCS = "tesla_ccs"
    case chaDemo = "chademo"
    case schuko = "schuko"
    case teslaSUC = "tesla_suc"
    case type1 = "type1"
    case type2 = "type2"
    case type3 = "type3"
}

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

// MARK: - Public object
struct ManufacturerAttributes: ResourceAttributes {
    static var typeName: String { "manufacturer" }
}

public struct Vehicule {

    public let id: String
    public let name: String
    public let brand: String
    public let chargePorts: [Plug]
    public let manufacturerID: String

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
