//
//  ContentView.swift
//  Shared
//
//  Created by eidd5180 on 25/03/2021.
//

import SwiftUI
import ChargepriceKit
import CoreLocation

struct ContentView: View {

    @State var items: [ChargingStation]  = []


    var body: some View {

        List(items) { item in
            Text(item.name)
        }.onAppear {

            let topLeft = CLLocationCoordinate2D(latitude: 6, longitude: 47)
            let bottomRight = CLLocationCoordinate2D(latitude: 7, longitude: 48)
            client.getChargingStation(topLeft: topLeft, bottomRight: bottomRight) { (result) in
                print("Result: \(result)")
                switch result {
                case .success(let items):
                    self.items = items
                case .failure(let failure):
                    print("Failure: \(failure)")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
