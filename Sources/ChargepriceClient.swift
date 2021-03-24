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

    public enum ClientError: Error {
        case network(Error)
        case apiError([ErrorObject])
        case emptyData
    }
    
    // MARK: - Concurrency
    private let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 10
        queue.qualityOfService = .utility
        return queue
    }()

    private let key: String

    init(key: String) {
        self.key = key
        super.init()
    }

    // MARK: - Internals | Networking
    @discardableResult
    private func requestOperation<End, Body, Encoding, ResponseBody, Decoding>(endpoint: End,
                                                                             encoding: CodingPart<Body, Encoding>?,
                                                                             decoding: Decoding?,
                                                                             completionCall: @escaping (Result<ResponseBody, Error>) -> Void) -> Cancellable
    where End: Endpoint,
          Encoding: FormatEncoder,
          Decoding: FormatDecoder,
          Body: Encodable,
          ResponseBody: Decodable {

        let op = RequestOperation(apiKey: self.key, endpoint: endpoint, encoding: encoding, decoding: decoding, completionCall: completionCall)
        self.queue.addOperation(op)
        return op
    }

    // MARK: - Internals | JSONSpec
    func getJSONSpec<End, Request, Data, Meta>(endpoint: End,
                                               request: Request,
                                               completion: @escaping (Result<OkDocument<Data, Meta>, ClientError>) -> Void) -> Cancellable
    where End: Endpoint,
          Request: Encodable,
          Data: Decodable,
          Meta: Decodable {

        let encoding = CodingPart(body: request, coding: JSONEncoder())
        let decoding = JSONDecoder()
        return self.requestOperation(endpoint: endpoint, encoding: encoding, decoding: decoding) { (result: Result<Document<Data, Meta>, Error>) in

            switch result {
            case .failure(let error):
                completion(.failure(ClientError.network(error)))
            case .success(let document):
                // NOTE: We still needs to check other cases from the specs
                if let error = document.errors {
                    completion(.failure(.apiError(error)))
                } else {
                    completion(.success(OkDocument(data: document.data, meta: document.meta)))
                }
            }
        }
    }


    public func getVehicules(completion: @escaping (Result<[Vehicule], ClientError>) -> Void) -> Cancellable {

        return self.getJSONSpec(endpoint: API.vehicules, request: NoCodingPartBody) { (result: Result<OkDocument<[ResourceObject<VehiculeAttributes, JSONSpecRelationShip<ManufacturerAttributes>>], NoData>, ClientError>)  in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let document):

                guard let data = document.data else {
                    completion(.failure(.emptyData))
                    return
                }
                let converted = data.map(Vehicule.init)
                completion(.success(converted))
            }
        }
    }

    
}

