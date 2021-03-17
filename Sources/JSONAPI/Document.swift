//
//  File.swift
//  
//
//  Created by Yannick Heinrich on 11.03.21.
//

import Foundation

struct ErrorObject: Decodable {

}

enum Either<L, R> {
    case left(L)
    case right(R)
}

struct NoData: Decodable { }

protocol ResourceAttributes {
    static var typeName: String { get }
}

struct ResourceObject<Attributes: ResourceAttributes>: Decodable where Attributes: Decodable {
    let id: String
    let attributes: Attributes
}

struct Document<Data, Meta> {
    let data: Data
    let meta: Meta?
}

struct DocumentInternal<Data, Meta>: Decodable where Data: Decodable, Meta: Decodable {

    private enum CodingKeys: String, CodingKey {
        case data
        case error
    }

    let data: Data?
    let content: Either<[ErrorObject], Meta>?

    // MARK: - Decodable
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let data =  try container.decodeIfPresent(Data.self, forKey: .data) {
            self.data = data
            self.content = nil
        } else if  let error = try container.decodeIfPresent([ErrorObject].self, forKey: .error) {
            self.data = nil
            self.content = .left(error)
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [CodingKeys.data, CodingKeys.error], debugDescription: "can not have both nil"))
        }
    }
    func decode() throws -> Document<Data, Meta> {

        switch (self.data, self.content) {

        }
    }
}

