//
//  TestAppApp.swift
//  Shared
//
//  Created by Yannick Heinrich on 25/03/2021.
//

import SwiftUI
import ChargepriceKit
import Combine
let client = ChargepriceClient(key: "API_KEY")


class Model {
    var cancellables: Set<AnyCancellable> = Set()

    init() {
        client.getVehiculesPublisher().sink { (error) in
            print("Error: \(error)")
        } receiveValue: { (values) in
            print("Values: \(values)")
        }.store(in: &cancellables)

    }
}


@main
struct TestAppApp: App {
    let model = Model()
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
