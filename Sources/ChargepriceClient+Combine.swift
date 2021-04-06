//
//  ChargepriceClient+Combine.swift
//  ChargepriceKit
//
//  Created by eidd5180 on 06/04/2021.
//

import Foundation

#if canImport(Combine)
import Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension ChargepriceClient {

    public func getVehiculePublishers() -> AnyPublisher<[Vehicule], ClientError> {
        return Publishers.ClientVehiculePub(client: self).eraseToAnyPublisher()
    }
}

// swiftlint:disable nesting
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Publishers {
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

    struct ClientVehiculePub: Publisher {

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
}
// swiftlint:enable nesting

#endif
