//
//  TestAppApp.swift
//  Shared
//
//  Created by eidd5180 on 25/03/2021.
//

import SwiftUI
import ChargepriceKit
import Combine
let client = ChargepriceClient(key: "eff7327bb000aebc176f844cd152a8b3")


class Model {
    var cancellables: Set<AnyCancellable> = Set()

    init() {
        client.getVehiculePublishers().sink { (error) in
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
