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

    let client = ChargepriceClient(key: "API_KEY")
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

        typealias DocumentType = Document<[ResourceObject<VehiculeAttributes, JSONSpecRelationShip<ManufacturerAttributes>>], NoData, NoData>
        let response: DocumentType = try assertUnmarshall(jsonName: "vehicule")
        XCTAssertNil(response.errors)
        let vehicules = response.data!.map(Vehicule.init)
        XCTAssertEqual(vehicules.count, 264)
    }

    func testChargingStationUnmarchall() throws {

        typealias DocumentType = Document<[ResourceObject<ChargingStationAttributes, JSONSpecRelationShip<OperatorAttributes>>], ChargingStationMeta, [ResourceObject<CompanyAttributes, NoData>]>
        let response: DocumentType = try assertUnmarshall(jsonName: "charging_stations")
        XCTAssertNil(response.errors)
        XCTAssertEqual(response.data!.count, 76)
    }

    func testTariffsUnmarchall() throws {

        typealias DocumentType = Document<[ResourceObject<TariffAttributes, NoData>], NoData, NoData>
        let response: DocumentType = try assertUnmarshall(jsonName: "tariffs")
        XCTAssertNil(response.errors)
        XCTAssertEqual(response.data!.count, 372)
    }

    func testErrorUnmarshall() throws {
        typealias DocumentType = Document<[ResourceObject<TariffAttributes, NoData>], NoData, NoData>
        let response: DocumentType = try assertUnmarshall(jsonName: "error")
        XCTAssertNotNil(response.errors)
        let error = response.errors![0]
        XCTAssertEqual(error.status, "403")

    }
}
