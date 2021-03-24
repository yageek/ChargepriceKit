//
//  File.swift
//  
//
//  Created by Yannick Heinrich on 11.03.21.
//

import Foundation

public struct ErrorObject: Decodable, Error { }


struct NoData: Decodable { }

protocol ResourceAttributes: Decodable {
    static var typeName: String { get }
}


struct OkDocument<Data, Meta>: Decodable where Data: Decodable, Meta: Decodable {
    let data: Data?
    let meta: Meta?
}

struct Document<Data, Meta>: Decodable where Data: Decodable, Meta: Decodable {

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

}

struct EmptyLeafKind: Decodable{ }
extension EmptyLeafKind: ResourceAttributes {
    static var typeName: String { "<empty>"}
}

let EmptyLeaf: EmptyLeafKind? = nil

struct LeafResource<Attributes: ResourceAttributes> {
    let id: String
    let attributes: Attributes
}

struct ResourceObject<Attributes: ResourceAttributes, RelationShip: ResourceAttributes, Included: ResourceAttributes>: Decodable {
    let id: String
    let attributes: Attributes
    let relationships: RelationShip?
    let included: Included?
}

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
        let _ = try decoder.decode(String.self, forKey: CodingKeys(stringValue: Attr.typeName)!)
        let id = try decoder.decode(String.self, forKey: CodingKeys(stringValue: "id")!)
        self.id = id

    }

    static var typeName: String { return Attr.typeName }
}
