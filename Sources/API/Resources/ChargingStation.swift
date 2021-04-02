//
//  ChargingStation.swift
//  ChargepriceKit
//
//  Created by eidd5180 on 24/03/2021.
//

import Foundation
import CoreLocation

public struct ChargePoint: Decodable {
    public let plug: Plug
    public let power: Float
    public let count: Int
    public let availableCount: Int

    enum CodingKeys: String, CodingKey {
       case plug
       case power
       case count
       case availableCount
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.plug = try container.decode(Plug.self, forKey: .plug)
        self.power = try container.decode(Float.self, forKey: .power)
        self.count = try container.decode(Int.self, forKey: .count)
        self.availableCount = try container.decodeIfPresent(Int.self, forKey: .availableCount) ?? 0
    }
}
struct ChargingStationAttributes: ResourceAttributes, Decodable {

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


struct OperatorAttributes: Decodable, ResourceAttributes {
    let `operator`: OkDocument<JSONSpecRelationShip<CompanyAttributes>, NoData, NoData>
    static var typeName: String { "operator" }
}

struct CompanyAttributes: ResourceAttributes {
    static var typeName: String { "company" }
    let name: String
}

public struct Operator {
    let id: String
    let name: String
}

public struct ChargingStation {

    public let `operator`: Operator
    public let name: String
    public let position: CLLocationCoordinate2D
    public let country: String
    public let address: String
    public let freeParking: Bool
    public let freeCharging: Bool
    public let chargePoints: [ChargePoint]
    public let id: String

    init(obj: ResourceObject<ChargingStationAttributes, JSONSpecRelationShip<OperatorAttributes>>, dict: [String: CompanyAttributes]) {
        self.id = obj.id
        self.name = obj.attributes.name
        self.position = obj.attributes.position
        self.country = obj.attributes.country
        self.address = obj.attributes.address
        self.freeParking = obj.attributes.freeParking
        self.freeCharging = obj.attributes.freeCharging
        self.chargePoints = obj.attributes.chargePoints

        // Now we fill operator from provided array
        let elements = dict[obj.relationships!.id]!
        self.operator = Operator(id: obj.relationships!.id, name: elements.name)
    }
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension ChargingStation: Identifiable { }
