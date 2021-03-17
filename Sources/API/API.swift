//
//  API.swift
//  ChargepriceKit
//
//  Created by Yannick Heinrich on 17.03.21.
//

import Foundation

private let chargepriceHost = URL(string: "https://api.chargeprice.app")!

enum API {
    case vehicules
}

extension API: Endpoint {
    var baseHost: URL { chargepriceHost }

    var path: String {
        switch self {
        case .vehicules:
            return "/v1/vehicles"
        }
    }

    var queryParameters: [String : String?] {
        [:]
    }

    var method: Method {
        .get
    }
}
