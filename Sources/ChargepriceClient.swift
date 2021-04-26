//
//  File.swift
//  
//
//  Created by Yannick Heinrich on 11.03.21.
//

import Foundation
import CoreLocation

// MARK: - Cancellable

/// A `Cancellable` action
@objc public protocol Cancellable {

    /// Cancel the current operation
    func cancel()
}

/// :nodoc:
extension Operation: Cancellable { }

// MARK: - Client

/// A client object that can query the `Chargeprice` API.
@objcMembers
public final class ChargepriceClient: NSObject {

    /// The errors returned during API calls.
    public enum ClientError: Error {
        /// Failed due to network
        case network(Error)
        /// API returns an error
        case apiError([ErrorObject])
        /// Unexpected empty data
        case emptyData
        /// Unexpected empty included
        case emptyIncluded
    }

    // MARK: - Concurrency
    let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 10
        queue.qualityOfService = .utility
        return queue
    }()

    private let key: String
    private let session: URLSession

    public init(session: URLSession = .shared, key: String) {
        self.key = key
        self.session = session
        super.init()
    }

    // MARK: - Internals | Networking
    private func createRequestOperation<End, Body, Encoding, ResponseBody, Decoding>(endpoint: End,
                                                                                     encoding: CodingPart<Body, Encoding>?,
                                                                                     decoding: Decoding?,
                                                                                     completionCall: @escaping (Result<ResponseBody, Error>) -> Void) -> Operation
    where End: Endpoint,
          Encoding: FormatEncoder,
          Decoding: FormatDecoder,
          Body: Encodable,
          ResponseBody: Decodable {

        let operation = RequestOperation(session: self.session, apiKey: self.key, endpoint: endpoint, encoding: encoding, decoding: decoding, completionCall: completionCall)
        return operation
    }

    // MARK: - Internals | JSONSpec
    func getJSONSpec<End, Request, Data, Meta, Included>(endpoint: End,
                                                         request: Request?,
                                                         completion: @escaping (Result<OkDocument<Data, Meta, Included>, ClientError>) -> Void) -> Operation
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
            return self.createRequestOperation(endpoint: endpoint, encoding: encoding, decoding: decoding, completionCall: completion)
        } else {
            return self.createRequestOperation(endpoint: endpoint, encoding: NoCodingPart, decoding: decoding, completionCall: completion)
        }

    }

    // MARK: - Public API
    func getVehiculesOperation(completion: @escaping (Result<[Vehicule], ClientError>) -> Void) -> Operation {
        let operation = self.getJSONSpec(endpoint: API.vehicules, request: NoCodingPartBody) { (result: Result<OkDocument<[ResourceObject<VehiculeAttributes, JSONSpecRelationShip<ManufacturerAttributes>>], NoData, NoData>, ClientError>)  in
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
        return operation

    }
    /// Load the vehicules
    /// - Parameter completion: The completion
    /// - Returns: A `Cancellable` element
    @discardableResult public func getVehicules(completion: @escaping (Result<[Vehicule], ClientError>) -> Void) -> Cancellable {
        let operation = self.getVehiculesOperation(completion: completion)
        self.queue.addOperation(operation)
        return operation
    }

    func getChargingStationOperation(topLeft: CLLocationCoordinate2D,
                                     bottomRight: CLLocationCoordinate2D,
                                     freeCharging: Bool? = nil,
                                     freeParking: Bool? = nil,
                                     power: Float? = nil,
                                     plugs: [Plug]? = nil,
                                     operatorID: String? = nil,
                                     completion: @escaping (Result<ChargingStationResponse, ClientError>) -> Void) -> Operation {

        let endpoint = API.chargingStations(topLeft: topLeft,
                                            bottomRight: bottomRight,
                                            freeCharging: freeCharging,
                                            freeParking: freeParking,
                                            power: power,
                                            plugs: plugs,
                                            operatorID: operatorID)

        let operation = self.getJSONSpec(endpoint: endpoint, request: NoCodingPartBody) { (result: Result<OkDocument<[ChargingStation.Ressource], ChargingStation.Meta, [ResourceObject<ChargingStation.Relationships, NoData>]>, ClientError>)  in

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

                let attributes = included.reduce(into: [String: ChargingStation.Relationships](), { $0[$1.id] = $1.attributes })
                let converted = data.map { ChargingStation(obj: $0, dict: attributes) }

                let response = ChargingStationResponse(stations: converted, disableGoingElectrics: document.meta!.countries)
                completion(.success(response))
            }
        }
        return operation
    }

    /// Get the charging stations
    /// - Parameters:
    ///   - topLeft: The topleft coordinate
    ///   - bottomRight: The bottom right coordinate
    ///   - freeCharging: Filter by free charging
    ///   - freeParking: Filter by free parking
    ///   - power: Filter by power
    ///   - plugs: Filter by plugs
    ///   - operatorID: filter by operatorID
    ///   - completion: The compltion block
    /// - Returns:  A `Cancellable` element
    @discardableResult public func getChargingStation(topLeft: CLLocationCoordinate2D,
                                                      bottomRight: CLLocationCoordinate2D,
                                                      freeCharging: Bool? = nil,
                                                      freeParking: Bool? = nil,
                                                      power: Float? = nil,
                                                      plugs: [Plug]? = nil,
                                                      operatorID: String? = nil,
                                                      completion: @escaping (Result<ChargingStationResponse, ClientError>) -> Void) -> Cancellable {

        let operation = getChargingStationOperation(topLeft: topLeft,
                                                    bottomRight: bottomRight,
                                                    freeCharging: freeCharging,
                                                    freeParking: freeParking,
                                                    power: power,
                                                    plugs: plugs,
                                                    operatorID: operatorID,
                                                    completion: completion)
        self.queue.addOperation(operation)
        return operation
    }

    func getTarrifsOperation(isDirectPayment: Bool? = nil, isProviderCustomerOnly: Bool? = nil, completion: @escaping (Result<[Tariff], ClientError>) -> Void) -> Operation {
        let endpoint = API.tariff(isDirectPayment: isDirectPayment, isProviderCustomerOnly: isProviderCustomerOnly)
        let operation = getJSONSpec(endpoint: endpoint, request: NoCodingPartBody) { (result: Result<OkDocument<[ResourceObject<TariffAttributes, NoData>], NoData, NoData>, ClientError>) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let document):

                guard let data = document.data else {
                    completion(.failure(.emptyData))
                    return
                }

                let elements = data.map(Tariff.init)
                completion(.success(elements))
            }
        }
        return operation
    }

    /// Get the tarrifs
    /// - Parameters:
    ///   - isDirectPayment: Filter by direct payment
    ///   - isProviderCustomerOnly: Filter by provider customer only
    ///   - completion: The completion block
    /// - Returns:  A `Cancellable` element
    @discardableResult public func getTarrifs(isDirectPayment: Bool? = nil, isProviderCustomerOnly: Bool? = nil, completion: @escaping (Result<[Tariff], ClientError>) -> Void) -> Cancellable {
        let operation = getTarrifsOperation(completion: completion)
        self.queue.addOperation(operation)
        return operation
    }

    func getCompaniesOperation(ids: [String]? = nil, fields: [String]? = nil, pageSize: Int? = nil, pageNumber: Int? = nil) -> Cancellable {
        let endpoint = API.companies(ids: ids, fields: fields, pageSize: pageSize, pageNumber: pageNumber)
        let operation = self.getJSONSpec(endpoint: endpoint, request: NoCodingPartBody) { (result: Result<OkDocument<[ResourceObject<CompanyAttributes, NoData>], NoData, NoData>, ClientError>) in
            print("Result: \(result)")
        }
        self.queue.addOperation(operation)
        return operation
    }
}
