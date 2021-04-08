//
//  File.swift
//  
//
//  Created by Yannick Heinrich on 11.03.21.
//

import Foundation

/// An error object returned by the API
public struct ErrorObject: Decodable, Error {

    /// The status of the error
    public let status: String

    /// The title of the error
    public let title: String
}

/// :nodoc:
struct NoData: Decodable { }

/// :nodoc:
extension NoData: ResourceAttributes {
    static var typeName: String = "NoData"
}

/// :nodoc:
protocol ResourceAttributes: Decodable {
    static var typeName: String { get }
}

/// :nodoc:
struct OkDocument<Data, Meta, Included>: Decodable where Data: Decodable, Meta: Decodable, Included: Decodable {
    let data: Data?
    let meta: Meta?
    let included: Included?
}

/// :nodoc:
struct Document<Data, Meta, Included>: Decodable where Data: Decodable, Meta: Decodable, Included: Decodable {

    private enum SpecError: Error {
        case invalidContent(String)
    }

    private struct APIError<Meta>: Error {
        let meta: Meta?
        let errors: [ErrorObject]
    }

    let data: Data?
    let meta: Meta?
    let errors: [ErrorObject]?
    let included: Included?
}

/// :nodoc:
struct EmptyLeafKind: Decodable { }
extension EmptyLeafKind: ResourceAttributes {
    static var typeName: String { "<empty>"}
}

/// :nodoc:
let EmptyLeaf: EmptyLeafKind? = nil

/// :nodoc:
struct ResourceObject<Attributes: ResourceAttributes, RelationShip: ResourceAttributes>: Decodable {
    let id: String
    let attributes: Attributes
    let relationships: RelationShip?
}

/// :nodoc:
struct JSONSpecRelationShip<Attr: ResourceAttributes>: Decodable, ResourceAttributes {
    let id: String

    struct CodingKeys: CodingKey {
        var stringValue: String

        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        var intValue: Int? { return nil}

        init?(intValue: Int) {
            fatalError("not used")
        }
    }

    init(from decoder: Decoder) throws {
        let decoder = try decoder.container(keyedBy: CodingKeys.self)

        let topContainer = try decoder.nestedContainer(keyedBy: CodingKeys.self,
                                                       forKey: CodingKeys(stringValue: Attr.typeName)!)
        let dataContainer = try topContainer.nestedContainer(keyedBy: CodingKeys.self,
                                                             forKey: CodingKeys(stringValue: "data")!)
        let id = try dataContainer.decode(String.self, forKey: CodingKeys(stringValue: "id")!)
        self.id = id
    }

    static var typeName: String { return Attr.typeName }
}
