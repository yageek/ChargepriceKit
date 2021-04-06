//
//  ChargingStation.swift
//  ChargepriceKit
//
//  Created by eidd5180 on 24/03/2021.
//

import Foundation
import CoreLocation

// MARK: - Internal
/// :nodoc:
struct ChargingStationAttributes: ResourceAttributes, Decodable {

    static var typeName: String { "charing_station" }

    let name: String
    let position: CLLocationCoordinate2D
    let country: String
    let address: String
    let freeParking: Bool?
    let freeCharging: Bool?
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

        self.freeParking = try container.decodeIfPresent(Bool.self, forKey: .freeParking)
        self.freeCharging = try container.decodeIfPresent(Bool.self, forKey: .freeCharging)
        self.chargePoints = try container.decode([ChargePoint].self, forKey: .chargePoints)
    }
}

/// :nodoc:
struct OperatorAttributes: Decodable, ResourceAttributes {
    let `operator`: OkDocument<JSONSpecRelationShip<CompanyAttributes>, NoData, NoData>
    static var typeName: String { "operator" }
}

/// :nodoc:
struct CompanyAttributes: ResourceAttributes {
    static var typeName: String { "company" }
    let name: String
}

/// :nodoc:
struct ChargingStationMeta: Decodable {
    let countries: [String]

    private enum CodingKeys: String, CodingKey {
        case countries = "disabled_going_electric_countries"
    }
}

// MARK: - Public

/// The chargepoint entity
public struct ChargePoint: Decodable {

    /// Available chargeports. See `Plug` for possible values
    public let plug: Plug

    /// The maximum power
    public let power: Float

    /// Total number of charge points of this type at the station
    public let count: Int

    /// Number of charge points of this type at the station, which are ready to use and not occupied. `nil` means unknown
    public let availableCount: Int?

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
        self.availableCount = try container.decodeIfPresent(Int.self, forKey: .availableCount)
    }
}

/// The operator entity
public struct Operator {

    /// The identifier of the `Operator`
    public let id: String

    /// The name of the `Operator`
    public let name: String
}

/// The `ChargingStation` entity
public struct ChargingStation {

    /// The identifier of the charging station
    public let id: String

    /// The operator relation
    public let `operator`: Operator

    /// The name of the station
    public let name: String

    /// The location of the station
    public let position: CLLocationCoordinate2D

    /// The ISO 3166 country code of the location
    public let country: String

    /// Address of the station
    public let address: String

    /// Parking at the station is free of charge (`nil` = unknown)
    public let freeParking: Bool?

    // Charging at the station is free of charge (`nil` = unknown)
    public let freeCharging: Bool?

    /// Charge points at this station, grouped by power and plug type
    public let chargePoints: [ChargePoint]

    /// :nodoc:
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

/// The response from a charging station request
public struct ChargingStationResponse {

    /// The stations
    public let stations: [ChargingStation]

    /// Countries where the Chargeprice Data has likely better quality than the GoingElectric data and hence the GoingElectric data shouldn't be shown at all.
    public let disableGoingElectrics: [String]
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension ChargingStation: Identifiable { }
