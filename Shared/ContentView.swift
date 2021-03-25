//
//  ContentView.swift
//  Shared
//
//  Created by eidd5180 on 25/03/2021.
//

import SwiftUI
import ChargepriceKit
struct ContentView: View {

    @State var items: [Vehicule]  = []


    var body: some View {

        List(items) { item in
            Text(item.name)
        }.onAppear {

            client.getVehicules { (result) in
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
