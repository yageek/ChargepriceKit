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

public struct Vehicule: Decodable, ResourceAttributes {
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
