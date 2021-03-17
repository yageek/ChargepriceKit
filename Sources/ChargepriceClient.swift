//
//  File.swift
//  
//
//  Created by Yannick Heinrich on 11.03.21.
//

import Foundation

// MARK: - Cancellable
@objc public protocol Cancellable {
    func cancel()
}

extension Operation: Cancellable { }

// MARK: - Client
@objcMembers
public final class ChargepriceClient: NSObject {

    // MARK: - Concurrency
    private let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 10
        queue.qualityOfService = .background
        return queue
    }()

    private let key: String

    init(key: String) {
        self.key = key
        super.init()
    }

    // MARK: - Internals
    @discardableResult
    private func requestOperation<E, Body, Encoding, ResponseBody, Decoding>(endpoint: E,
                                                                             encoding: CodingPart<Body, Encoding>?,
                                                                             decoding: Decoding?,
                                                                             completionCall: @escaping (Result<ResponseBody, Error>) -> Void) -> Cancellable
    where E: Endpoint,
          Encoding: FormatEncoder,
          Decoding: FormatDecoder,
          Body: Encodable,
          ResponseBody: Decodable {

        let op = RequestOperation(apiKey: self.key, endpoint: endpoint, encoding: encoding, decoding: decoding, completionCall: completionCall)
        self.queue.addOperation(op)
        return op
    }

    // MARK: - Public
    public func getVehicules(completion: @escaping (Result<Document<[Vehicule], NoData>, Error>) -> Void) -> Cancellable {

        typealias Response = DocumentInternal<[ResourceObject<Vehicule>], NoData>
        return self.requestOperation(endpoint: API.vehicules, encoding: NoCodingPart, decoding: JSONDecoder()) { (result: Result<Response, Error>) in
            let element = result.flatMap { (response) -> Result<[Vehicule], Error> in
                do {
                    let document = try response.parse()
                    return .success(document)
                } catch let error {
                    return .failure(error)
                }
            }
            completion(element)
        }

    }
}

