//
//  File.swift
//  
//
//  Created by Yannick Heinrich on 11.03.21.
//

import Foundation

enum Method: String {
    case get = "GET", post = "POST", put = "PUT"
}

protocol Endpoint {
    var baseHost: URL { get }
    var path: String { get }
    var queryParameters: [String: String?] { get }
    var method: Method { get }
}
