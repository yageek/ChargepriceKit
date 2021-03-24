//
//  ChargepriceKitTests.swift
//  ChargepriceKitTests
//
//  Created by Yannick Heinrich on 11.03.21.
//

import XCTest
import Foundation
@testable import ChargepriceKit

class ChargepriceKitTests: XCTestCase {

    let client = ChargepriceClient(key: "eff7327bb000aebc176f844cd152a8b3")
    let sampleBundle: Bundle = {
        let testBundle = Bundle(for: ChargepriceKitTests.self)
        let sampleBundleURL = testBundle.url(forResource: "samples", withExtension: "bundle")!
        let bundleURL = Bundle(url: sampleBundleURL)!
        return bundleURL
    }()


    func getSample(name: String)  -> Data {
        let url = sampleBundle.url(forResource: name, withExtension: "json")!
        return try! Data(contentsOf: url)
    }


    func testUnmarchall() throws {

        let vehiculeData = getSample(name: "vehicule")

        let decoder = JSONDecoder()
        var response: Document<[ResourceObject<VehiculeAttributes, ManufacturerAttributes>], NoData>!
        XCTAssertNoThrow(response = try decoder.decode(Document<[ResourceObject<VehiculeAttributes, ManufacturerAttributes>], NoData>.self, from: vehiculeData))

        XCTAssertEqual(response.data!.count, 264)
    }

    func testCall() throws {

        let exp = XCTestExpectation(description: "wait")
        client.getVehicules { (result) in
            exp.fulfill()
        }

        wait(for: [exp], timeout: 10.0)
    }
}
