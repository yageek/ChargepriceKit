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

public struct Document<Data, Meta> {
    public let data: Data?
    public let meta: Meta?
}

struct DocumentInternal<Data, Meta>: Decodable where Data: Decodable, Meta: Decodable {

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

    func parse() throws -> Document<Data, Meta> {

        switch (self.data, self.meta, self.errors) {
        case (let data?, let meta, nil):
            return Document(data: data, meta: meta)
        case (.none, .none, .none):
            throw SpecError.invalidContent("everything nil. forbidden")
        case (.some(_), _, .some(_)):
            throw SpecError.invalidContent("data and errors not nil. forbidden")
        case (.none, let meta, let errors?):
            throw APIError(meta: meta, errors: errors)
        case (.none, let meta, .none):
            return Document(data: nil, meta: meta)
        }
    }
}

