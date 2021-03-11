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

struct Document<Data, Meta> where Data: Decodable, Meta: Decodable {
    let data: Data
    let content: Either<[ErrorObject], Meta>
}
