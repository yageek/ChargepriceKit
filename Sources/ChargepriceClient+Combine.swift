//
//  ChargepriceClient+Combine.swift
//  ChargepriceKit
//
//  Created by Yannick Heinrich on 06/04/2021.
//

#if canImport(Combine)
import Combine
import Foundation
import CoreLocation

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension ChargepriceClient {

    /// Load the vehicules
    /// - Returns: A `AnyPublisher` for `[Vehicule]`
    public func getVehiculesPublisher() -> AnyPublisher<[Vehicule], ClientError> {
        return Publishers.ClientVehicule(client: self).eraseToAnyPublisher()
    }

    /// Load the tarrifs
    /// - Parameters:
    ///   - isDirectPayment: Filter by direct payment
    ///   - isProviderCustomerOnly: Filter by provider customer only
    /// - Returns: A `AnyPublisher` for `[Tarrif]`
    public func getTarrifsPublisher(isDirectPayment: Bool? = nil, isProviderCustomerOnly: Bool? = nil) -> AnyPublisher<[Tariff], ClientError> {
        return Publishers.ClientTarrifs(client: self, isDirectPayment: isDirectPayment, isProviderCustomerOnly: isProviderCustomerOnly).eraseToAnyPublisher()
    }

    // Get the charging stations
    /// - Parameters:
    ///   - topLeft: The topleft coordinate
    ///   - bottomRight: The bottom right coordinate
    ///   - freeCharging: Filter by free charging
    ///   - freeParking: Filter by free parking
    ///   - power: Filter by power
    ///   - plugs: Filter by plugs
    ///   - operatorID: filter by operatorID
    ///   - completion: The compltion block
    /// - Returns:  A `AnyPublisher` for `ChargingStationResponse`
    public func getChargingStationsPublishers(topLeft: CLLocationCoordinate2D,
                                              bottomRight: CLLocationCoordinate2D,
                                              freeCharging: Bool? = nil,
                                              freeParking: Bool? = nil,
                                              power: Float? = nil,
                                              plugs: [Plug]? = nil,
                                              operatorID: String? = nil) -> AnyPublisher<ChargingStationResponse, ClientError> {

        return Publishers.ClientChargingStations(client: self, topLeft: topLeft, bottomRight: bottomRight, freeCharging: freeCharging, freeParking: freeParking, power: power, plugs: plugs, operatorID: operatorID).eraseToAnyPublisher()
    }
}

// swiftlint:disable nesting
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Publishers {
    // MARK: - Subscription
    final class ClientSubscription<Output, S: Subscriber>: Subscription where S.Input == Output, S.Failure == ChargepriceClient.ClientError {

        private var operation: Operation
        private let queue: OperationQueue
        private let subscriber: S

        init(queue: OperationQueue, subscriber: S, operation: Operation) {
            self.queue = queue
            self.subscriber = subscriber
            self.operation = operation
        }

        func request(_ demand: Subscribers.Demand) {
            self.queue.addOperation(self.operation)
        }

        func cancel() {
            self.operation.cancel()
        }
    }

    // MARK: - Vehicules
    struct ClientVehicule: Publisher {

        typealias Failure = ChargepriceClient.ClientError
        typealias Output = [Vehicule]

        let client: ChargepriceClient
        init(client: ChargepriceClient) {
            self.client = client
        }

        func receive<S>(subscriber: S) where S: Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
            let sub = ClientSubscription(queue: self.client.queue, subscriber: subscriber, operation: client.getVehiculesOperation(completion: { (result) in
                switch result {
                case .failure(let error):
                    subscriber.receive(completion: .failure(error))
                case .success(let value):
                    _ = subscriber.receive(value)
                    subscriber.receive(completion: .finished)
                }
            }))
            subscriber.receive(subscription: sub)
        }
    }

    // MARK: - Tariffs
    struct ClientTarrifs: Publisher {

        typealias Failure = ChargepriceClient.ClientError
        typealias Output = [Tariff]

        let client: ChargepriceClient
        let isDirectPayment: Bool?
        let isProviderCustomerOnly: Bool?

        init(client: ChargepriceClient, isDirectPayment: Bool?, isProviderCustomerOnly: Bool?) {
            self.client = client
            self.isDirectPayment = isDirectPayment
            self.isProviderCustomerOnly = isProviderCustomerOnly
        }

        func receive<S>(subscriber: S) where S: Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
            let sub = ClientSubscription(queue: self.client.queue, subscriber: subscriber, operation: client.getTarrifsOperation(isDirectPayment: isDirectPayment, isProviderCustomerOnly: isProviderCustomerOnly, completion: { (result) in
                switch result {
                case .failure(let error):
                    subscriber.receive(completion: .failure(error))
                case .success(let value):
                    _ = subscriber.receive(value)
                    subscriber.receive(completion: .finished)
                }
            }))
            subscriber.receive(subscription: sub)
        }
    }

    // MARK: - Charging Station
    struct ClientChargingStations: Publisher {

        typealias Failure = ChargepriceClient.ClientError
        typealias Output = ChargingStationResponse

        let client: ChargepriceClient
        let topLeft: CLLocationCoordinate2D
        let bottomRight: CLLocationCoordinate2D
        let freeCharging: Bool?
        let freeParking: Bool?
        let power: Float?
        let plugs: [Plug]?
        let operatorID: String?

        init(client: ChargepriceClient, topLeft: CLLocationCoordinate2D,
             bottomRight: CLLocationCoordinate2D,
             freeCharging: Bool? = nil,
             freeParking: Bool? = nil,
             power: Float? = nil,
             plugs: [Plug]? = nil,
             operatorID: String? = nil) {
            self.client = client
            self.topLeft = topLeft
            self.bottomRight = bottomRight
            self.freeCharging = freeCharging
            self.freeParking = freeParking
            self.power = power
            self.plugs = plugs
            self.operatorID = operatorID
        }

        func receive<S>(subscriber: S) where S: Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {

            let operation = client.getChargingStationOperation(topLeft: self.topLeft,
                                                               bottomRight: self.bottomRight,
                                                               freeCharging: self.freeCharging,
                                                               freeParking: self.freeParking,
                                                               power: self.power,
                                                               plugs: self.plugs,
                                                               operatorID: self.operatorID) { (result) in
                switch result {
                case .failure(let error):
                    subscriber.receive(completion: .failure(error))
                case .success(let value):
                    _ = subscriber.receive(value)
                    subscriber.receive(completion: .finished)
                }
            }

            let sub = ClientSubscription(queue: self.client.queue, subscriber: subscriber, operation: operation)
            subscriber.receive(subscription: sub)
        }
    }

}
// swiftlint:enable nesting

#endif
