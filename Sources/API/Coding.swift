//
//  File.swift
//  
//
//  Created by Yannick Heinrich on 11.03.21.
//

import Foundation

protocol Format {
    var mimeType: String { get }
}

protocol FormatEncoder: Format {
    func encode<T>(_ value: T) throws -> Data where T: Encodable
}

protocol FormatDecoder: Format {
    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable
}

extension JSONEncoder: FormatEncoder {
    var mimeType: String { "application/json" }
}

extension JSONDecoder: FormatDecoder {
    var mimeType: String { "application/json" }
}
