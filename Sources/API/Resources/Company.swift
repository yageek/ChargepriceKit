//
//  Company.swift
//  ChargepriceKit
//
//  Created by Yannick Heinrich on 02.04.21.
//

import Foundation

/// :nodoc:
struct CompanyAttributes: ResourceAttributes, Decodable {

    static var typeName: String { "company" }
    let name: String
    let createdAt: Date
    let updatedAt: Date
    let version: Int
    let url: String
    let isCpo, isEmp: Bool

    enum CodingKeys: String, CodingKey {
        case name
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case version, url
        case isCpo = "is_cpo"
        case isEmp = "is_emp"
    }

    struct Meta: Decodable {
        let overallCount: Int

        enum CodingKeys: String, CodingKey {
            case overallCount = "overall_count"
        }
    }
}

public struct Company {

    let name: String
    let createdAt: Date
    let updatedAt: Date
    let version: Int
    let url: String
    let isCpo, isEmp: Bool

}
