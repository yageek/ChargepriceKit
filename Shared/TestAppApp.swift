//
//  TestAppApp.swift
//  Shared
//
//  Created by eidd5180 on 25/03/2021.
//

import SwiftUI
import ChargepriceKit

let client = ChargepriceClient(key: "eff7327bb000aebc176f844cd152a8b3")

@main
struct TestAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
