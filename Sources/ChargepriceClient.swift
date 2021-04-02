//
//  File.swift
//  
//
//  Created by Yannick Heinrich on 11.03.21.
//

import Foundation
import CoreLocation

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
        case emptyIncluded
    }
    
    // MARK: - Concurrency
    private let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 10
        queue.qualityOfService = .utility
        return queue
    }()

    private let key: String

    public init(key: String) {
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
    @discardableResult func getJSONSpec<End, Request, Data, Meta, Included>(endpoint: End,
                                               request: Request?,
                                               completion: @escaping (Result<OkDocument<Data, Meta, Included>, ClientError>) -> Void) -> Cancellable
    where End: Endpoint,
          Request: Encodable,
          Data: Decodable,
          Meta: Decodable,
          Included: Decodable {


        let decoding = JSONDecoder()

        let completion = { (result: Result<Document<Data, Meta, Included>, Error>) in

            switch result {
            case .failure(let error):
                completion(.failure(ClientError.network(error)))
            case .success(let document):
                // NOTE: We still needs to check other cases from the specs
                if let error = document.errors {
                    completion(.failure(.apiError(error)))
                } else {
                    completion(.success(OkDocument(data: document.data, meta: document.meta, included: document.included)))
                }
            }
        }

        if let request = request {
            let encoding = CodingPart(body: request, coding: JSONEncoder())
            return self.requestOperation(endpoint: endpoint, encoding: encoding, decoding: decoding, completionCall: completion)
        } else {
            return self.requestOperation(endpoint: endpoint, encoding: NoCodingPart, decoding: decoding, completionCall: completion)
        }

    }

    // MARK: - Public API

    /// Load the vehicules
    /// - Parameter completion: The completion
    /// - Returns: A `Cancellable` element
    @discardableResult public func getVehicules(completion: @escaping (Result<[Vehicule], ClientError>) -> Void) -> Cancellable {

        return self.getJSONSpec(endpoint: API.vehicules, request: NoCodingPartBody) { (result: Result<OkDocument<[ResourceObject<VehiculeAttributes, JSONSpecRelationShip<ManufacturerAttributes>>], NoData, NoData>, ClientError>)  in
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

    @discardableResult public func getChargingStation(topLeft: CLLocationCoordinate2D, bottomRight: CLLocationCoordinate2D, freeCharging: Bool? = nil, freeParking: Bool? = nil, power: Float? = nil, plugs: [Plug]? = nil, operatorID: String? = nil, completion: @escaping (Result<[ChargingStation], ClientError>) -> Void) -> Cancellable {

        let endpoint = API.chargingStations(topLeft: topLeft, bottomRight: bottomRight, freeCharging: freeCharging, freeParking: freeParking, power: power, plugs: plugs, operatorID: operatorID)

        return self.getJSONSpec(endpoint: endpoint, request: NoCodingPartBody) { (result: Result<OkDocument<[ResourceObject<ChargingStationAttributes, JSONSpecRelationShip<OperatorAttributes>>], NoData, [ResourceObject<CompanyAttributes, NoData>]>, ClientError>)  in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let document):

                guard let data = document.data else {
                    completion(.failure(.emptyData))
                    return
                }

                guard let included = document.included else {
                    completion(.failure(.emptyIncluded))
                    return
                }

                let attributes = included.reduce(into: [String: CompanyAttributes](), { $0[$1.id] = $1.attributes })
                let converted = data.map { ChargingStation(obj: $0, dict: attributes) }
                completion(.success(converted))
            }
        }
    }
}

