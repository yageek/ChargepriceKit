//
//  File.swift
//  
//
//  Created by Yannick Heinrich on 11.03.21.
//

import Foundation
import OSLog
/// :nodoc:
struct CodingPart<Body, Coding> {
    let body: Body
    let coding: Coding
}

/// :nodoc:
let NoCodingPartBody: Int? = nil
/// :nodoc:
let NoCodingPart: CodingPart<Int?, JSONEncoder>? = nil

/// :nodoc:
final class RequestOperation<E: Endpoint, Body: Encodable, Encoding: FormatEncoder, ResponseBody: Decodable, Decoding: FormatDecoder>: BaseOperation {

    private enum RequestError: Error {
        case invalidURL
        case noData(HTTPURLResponse)
    }

    // MARK: - iVar | Input
    private let session: URLSession
    private let apiKey: String
    private let encoding: CodingPart<Body, Encoding>?
    private let decoding: Decoding?
    private let endpoint: E
    private let completionCall: (Result<ResponseBody, Error>) -> Void

    // MARK: - iVar | Session state
    private var dataTask: URLSessionTask?

    // MARK: - Init
    init(session: URLSession = .shared,
         apiKey: String,
         endpoint: E,
         encoding: CodingPart<Body, Encoding>?,
         decoding: Decoding?,
         completionCall: @escaping (Result<ResponseBody, Error>) -> Void) {
        self.session = session
        self.apiKey = apiKey
        self.encoding = encoding
        self.decoding = decoding
        self.endpoint = endpoint
        self.completionCall = completionCall
        super.init()
        self.name = "net.yageek.chargepricekit"
    }

    override var isAsynchronous: Bool { return true}

    // MARK: - Main
    override func start() {
        self.isExecuting = true
        self.main()
    }

    override func main() {

        guard !self.isCancelled else { self.finish(); return }

        do {
            let url = try RequestOperation.encodeURL(endpoint: self.endpoint)
            let request = try RequestOperation.createRequest(url: url, key: self.apiKey, endpoint: self.endpoint, part: self.encoding)

            let task = self.session.dataTask(with: request) { [weak self] (data, response, error) in
                self?.handleResponse(data: data, response: response as? HTTPURLResponse, error: error)
            }

            self.dataTask = task
            task.resume()

        } catch let error {
            os_log("encoding error: ${private}@", log: logger, type: .error, error.localizedDescription)
            self.finishWithError(error)
        }
    }

    private func handleResponse(data: Data?, response: HTTPURLResponse?, error: Error?) {

        if let error = error {
            os_log("session error: ${private}@", log: logger, type: .error, error.localizedDescription)
            self.finishWithError(error)
        } else if let response = response {

            if let decoding = self.decoding {

                guard let data = data else {
                    self.finishWithError(RequestError.noData(response))
                    return
                }

                do {
                    let value = try decoding.decode(ResponseBody.self, from: data)
                    self.finishWithSuccess(value)
                } catch let error {
                    self.finishWithError(error)
                }
            }
        }
    }

    // MARK: - Cancel
    override func cancel() {
        self.dataTask?.cancel()
        super.cancel()
    }

    // MARK: - Finish
    private func finishWithError(_ error: Error) {
        self.completionCall(.failure(error))
        self.finish()
    }

    private func finishWithSuccess(_ value: ResponseBody) {
        self.completionCall(.success(value))
        self.finish()
    }

    // MARK: - Encoding
    static func createRequest(url: URL,
                              key: String,
                              endpoint: E,
                              part: CodingPart<Body, Encoding>?) throws -> URLRequest {

        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 20.0)

        request.httpMethod = endpoint.method.rawValue

        var headers: [String: String] = [
            "user-agent": "ChargepriceKit 0.0.1",
            "api-key": key
        ]

        if let part = part {
            let data = try part.coding.encode(part.body)
            request.httpBody = data
            headers["content-type"] = part.coding.mimeType
        }

        request.allHTTPHeaderFields = headers
        return request
    }

    static func encodeURL(endpoint: E) throws -> URL {

        guard var components = URLComponents(url: endpoint.baseHost, resolvingAgainstBaseURL: true) else {
            throw RequestError.invalidURL
        }

        components.path = endpoint.path
        components.queryItems = endpoint.queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        guard let url = components.url else { throw RequestError.invalidURL }
        return url
    }
}
