//
//  ContentView.swift
//  Shared
//
//  Created by Yannick Heinrich on 25/03/2021.
//

import SwiftUI
import ChargepriceKit
import CoreLocation
import Combine
struct ContentView: View {


    @State var items: [ChargingStation]  = []


    var body: some View {

        List(items) { item in
            Text(item.operator.name)
        }.onAppear {

//            let topLeft = CLLocationCoordinate2D(latitude: 47, longitude: 6)
//            let bottomRight = CLLocationCoordinate2D(latitude: 48, longitude: 7)
//            client.getChargingStation(topLeft: topLeft, bottomRight: bottomRight) { (result) in
//                print("Result: \(result)")
//                switch result {
//                case .success(let items):
//                    self.items = items
//                case .failure(let failure):
//                    print("Failure: \(failure)")
//                }
//            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
