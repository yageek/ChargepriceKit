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


    @discardableResult func assertUnmarshall<T: Decodable>(jsonName: String, file: StaticString = #filePath, line: UInt = #line) throws -> T {
        let vehiculeData = getSample(name: jsonName)

        let decoder = JSONDecoder()

        do {
            let response = try decoder.decode(T.self, from: vehiculeData)
            return response
        } catch let error {
            XCTFail(error.localizedDescription, file: file, line: line)
            throw error
        }
    }

    func testVehiculeUnmarchall() throws {

        typealias DocumentType =  Document<[ResourceObject<VehiculeAttributes, ManufacturerAttributes, EmptyLeafKind>], NoData>
        let response: DocumentType = try assertUnmarshall(jsonName: "vehicule")
        XCTAssertEqual(response.data!.count, 264)
    }

    func testChargingStationUnmarchall() throws {

        typealias DocumentType =  Document<[ResourceObject<ChargingStationAttributes, CompanyAttributes, EmptyLeafKind>], NoData>
        let response: DocumentType = try assertUnmarshall(jsonName: "charging_stations")
        XCTAssertEqual(response.data!.count, 76)
    }

}
