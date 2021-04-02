//
//  API.swift
//  ChargepriceKit
//
//  Created by Yannick Heinrich on 17.03.21.
//

import Foundation
import CoreLocation

private let chargepriceHost = URL(string: "https://api.chargeprice.app")!

enum API {
    case vehicules
    case chargingStations(topLeft: CLLocationCoordinate2D, bottomRight: CLLocationCoordinate2D, freeCharging: Bool?, freeParking: Bool?, power: Float?, plugs: [Plug]?, operatorID: String?)
    case tariff(isDirectPayment: Bool?, isProviderCustomerOnly: Bool?)
}
extension API: Endpoint {
    var baseHost: URL { chargepriceHost }

    var path: String {
        switch self {
        case .vehicules:
            return "/v1/vehicles"
        case .chargingStations:
            return "/v1/charging_stations"
        case .tariff:
            return "/v1/tariffs"
        }
    }

    var queryParameters: [String : String?] {
        switch self {
        case .chargingStations(topLeft: let topLeft, bottomRight: let bottomRight, freeCharging: let freeCharging, freeParking: let freeParking, power: let power, plugs: let plugs, operatorID: let opID):

            var filter: [String: String] = [
                "latitude.gte": "\(topLeft.latitude)",
                "latitude.lte": "\(bottomRight.latitude)",
                "longitude.gte": "\(topLeft.longitude)",
                "longitude.lte": "\(bottomRight.longitude)"
            ]

            if let freeCharging = freeCharging {
                filter["free_charging"] = "\(freeCharging)"
            }

            if let freeParking = freeParking {
                filter["free_parking"] = "\(freeParking)"
            }

            if let power = power {
                filter["charge_points.power.gte"] = "\(power)"
            }

            if let plugs = plugs, !plugs.isEmpty {
                filter["charge_points.plug.in"] = plugs.map { $0.rawValue }.joined(separator: ",")
            }

            if let opID = opID {
                filter["operator.id"] = "\(opID)"
            }

            let serialized = Dictionary(uniqueKeysWithValues: filter.map { ("filter[\($0.0)]", $0.1) })
            return serialized
        case .tariff(isDirectPayment: let isDirectPayment, isProviderCustomerOnly: let isProviderCustomerOnly):

            var filter: [String: String] = [:]
            if let payment = isDirectPayment {
                filter["direct_payment"] = payment ? "true" : "false"
            }

            if let customer = isProviderCustomerOnly {
                filter["direct_payment"] = customer ? "true" : "false"
            }

            let serialized = Dictionary(uniqueKeysWithValues: filter.map { ("filter[\($0.0)]", $0.1) })
            return serialized
        case .vehicules:
            return [:]
        }
    }

    var method: Method {
        .get
    }
}
