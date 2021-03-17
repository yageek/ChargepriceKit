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
        var response: Document<[ResourceObject<Vehicule>], NoData>!
        XCTAssertNoThrow(response = try decoder.decode(DocumentInternal<[ResourceObject<Vehicule>], NoData>.self, from: vehiculeData))

        XCTAssertEqual(response.data!.count, 264)
        
    }
}
