//
//  ChargingStation.swift
//  ChargepriceKit
//
//  Created by eidd5180 on 24/03/2021.
//

import Foundation
import CoreLocation

struct ChargingStationAttributes: ResourceAttributes, Decodable {

    struct ChargePoint: Decodable {
        let plug: Plug
        let power: Float
        let count: Int
        let availableCount: Int

        enum CodingKeys: String, CodingKey {
           case plug
           case power
           case count
           case availableCount
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            self.plug = try container.decode(Plug.self, forKey: .plug)
            self.power = try container.decode(Float.self, forKey: .power)
            self.count = try container.decode(Int.self, forKey: .count)
            self.availableCount = try container.decodeIfPresent(Int.self, forKey: .availableCount) ?? 0
        }
    }


    static var typeName: String  { "charing_station" }

    let name: String
    let position: CLLocationCoordinate2D
    let country: String
    let address: String
    let freeParking: Bool
    let freeCharging: Bool
    let chargePoints: [ChargePoint]

    enum CodingKeys: String, CodingKey {
        case name
        case latitude
        case longitude
        case country
        case address
        case freeParking = "free_parking"
        case freeCharging = "free_charging"
        case chargePoints = "charge_points"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.name = try container.decode(String.self, forKey: .name)

        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)

        self.country = try container.decode(String.self, forKey: .country)

        self.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

        self.address = try container.decode(String.self, forKey: .address)

        self.freeParking = try container.decodeIfPresent(Bool.self, forKey: .freeParking) ?? false
        self.freeCharging = try container.decodeIfPresent(Bool.self, forKey: .freeCharging) ?? false
        self.chargePoints = try container.decode([ChargePoint].self, forKey: .chargePoints)
    }
}


struct Operator: Decodable, ResourceAttributes {
    let `operator`: OkDocument<JSONSpecRelationShip<CompanyAttributes>, NoData>
    static var typeName: String { "operator" }
}

struct CompanyAttributes: ResourceAttributes {
    static var typeName: String { "company" }
    let name: String
}

