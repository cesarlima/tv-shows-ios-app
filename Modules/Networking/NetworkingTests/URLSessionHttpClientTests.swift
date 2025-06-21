import XCTest
import Foundation
@testable import Networking

final class URLSessionHttpClient {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func perform(_ request: HTTPRequest) async throws -> HTTPResult {
        do {
            let (data, response) = try await session.data(for: request.asURLRequest())
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                throw HTTPErrorMapper.mapHTTPResponse(httpResponse)
            }
            
            return HTTPResult(data: data, response: httpResponse)
        } catch let error as HTTPClientError {
            throw error
        } catch {
            throw HTTPErrorMapper.map(error, response: nil)
        }
    }
}

struct HTTPResult {
    let data: Data
    let response: HTTPURLResponse
}

protocol HTTPRequest {
    var host: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var body: HTTPBody { get }
}

extension HTTPRequest {
    func asURLRequest() throws -> URLRequest {
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        components.path = path
        var request = URLRequest(url: components.url!)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.httpBody = try body.encode()
        return request
    }
}

struct HTTPBody {
    let defaultHeaders: [String: String]
    let encode: () throws -> Data
    
    static func empty() -> HTTPBody {
        return HTTPBody(defaultHeaders: [:], encode: { Data() })
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum HTTPClientError: LocalizedError, Equatable {
    case invalidURL
    case networkError(underlying: Error)
    case serverError(statusCode: Int)
    case clientError(statusCode: Int)
    case timeout
    case noConnection
    case unauthorized
    case forbidden
    case notFound
    case internalServerError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL provided"
        case .networkError(let underlying):
            return "Network error: \(underlying.localizedDescription)"
        case .serverError(let statusCode):
            return "Server error with status code: \(statusCode)"
        case .clientError(let statusCode):
            return "Client error with status code: \(statusCode)"
        case .timeout:
            return "Request timed out"
        case .noConnection:
            return "No internet connection"
        case .unauthorized:
            return "Unauthorized access"
        case .forbidden:
            return "Access forbidden"
        case .notFound:
            return "Resource not found"
        case .internalServerError:
            return "Internal server error"
        case .unknown:
            return "Unknown error occurred"
        }
    }
    
    static func == (lhs: HTTPClientError, rhs: HTTPClientError) -> Bool {
        return lhs.errorDescription == rhs.errorDescription
    }
}

struct HTTPErrorMapper {
    static func map(_ error: Error, response: URLResponse?) -> HTTPClientError {
        // Handle URLSession errors
        if let urlError = error as? URLError {
            return mapURLError(urlError)
        }
        
        // Handle other errors
        return .networkError(underlying: error)
    }
    
    private static func mapURLError(_ error: URLError) -> HTTPClientError {
        switch error.code {
        case .notConnectedToInternet, .networkConnectionLost:
            return .noConnection
        case .timedOut:
            return .timeout
        case .badURL, .unsupportedURL:
            return .invalidURL
        default:
            return .networkError(underlying: error)
        }
    }
    
    static func mapHTTPResponse(_ response: HTTPURLResponse) -> HTTPClientError {
        switch response.statusCode {
        case 401:
            return .unauthorized
        case 403:
            return .forbidden
        case 404:
            return .notFound
        case 500...599:
            return .internalServerError
        case 400...499:
            return .clientError(statusCode: response.statusCode)
        default:
            return .unknown
        }
    }
}

final class URLSessionHttpClientTests: XCTestCase {
    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequests()
    }
    
    func test_init_doesNotPerformAnyRequest() {
        _ = URLSessionHttpClient()
        
        XCTAssertEqual(URLProtocolStub.requestsCount, 0)
    }

    func test_perform_performsRequestUsingCorrectHTTPRequest() async {
        let request = GetRequestMock()
        let sut = URLSessionHttpClient()

        let exp = expectation(description: "Wait for request")
        URLProtocolStub.stub(data: makeValidData(), response: makeHTTPURLResponse(), error: nil)
        URLProtocolStub.observeRequest { receivedRequest in
            XCTAssertEqual(receivedRequest.url, request.url)
            XCTAssertEqual(receivedRequest.httpMethod, request.method.rawValue)
            exp.fulfill()
        }

        do {
            _ = try await sut.perform(request)
        } catch {
            XCTFail("Expected success, got \(error)")
        }

        await fulfillment(of: [exp], timeout: 1)
    }
    
    func test_perform_failsOnHTTPClientCompletesWithAnError() async {
        let request = GetRequestMock()
        let sut = URLSessionHttpClient()
   
        URLProtocolStub.stub(data: nil, response: nil, error: makeError())
        
        do {
            _ = try await sut.perform(request)
            XCTFail("Expected error to be thrown")
        } catch {
            // Expected to throw an error
        }
    }
    
    func test_perform_mapsURLErrorToDomainError() async {
        await assertForURLError(with: .notConnectedToInternet, expectedError: .noConnection)
        await assertForURLError(with: .networkConnectionLost, expectedError: .noConnection)
        await assertForURLError(with: .badURL, expectedError: .invalidURL)
        await assertForURLError(with: .unsupportedURL, expectedError: .invalidURL)
        await assertForURLError(with: .timedOut, expectedError: .timeout)
        await assertForURLError(with: .cancelled, expectedError: .networkError(underlying: URLError(.cancelled)))
    }
    
    func test_perform_mapsHTTPStatusCodesToDomainErrors() async {
        await assertFailedResponse(for: 404, expectedError: .notFound)
        await assertFailedResponse(for: 401, expectedError: .unauthorized)
        await assertFailedResponse(for: 403, expectedError: .forbidden)
        await assertFailedResponse(for: 500, expectedError: .internalServerError)
        await assertFailedResponse(for: 429, expectedError: .clientError(statusCode: 429))
        await assertFailedResponse(for: 999, expectedError: .unknown)
    }
    
    func test_perform_completesWithHTTPResultOnSuccess() async {
        let request = GetRequestMock()
        let sut = URLSessionHttpClient()
        let expectedData = makeValidData()
        
        URLProtocolStub.stub(data: expectedData, response: makeHTTPURLResponse(), error: nil)
        
        do {
            let result = try await sut.perform(request)
            XCTAssertEqual(result.data, expectedData)
            XCTAssertEqual(result.response.url, request.url)
        } catch {
            XCTFail("Expected success, got \(error)")
        }
    }
    
    private func assertFailedResponse(for statusCode: Int,
                                      expectedError: HTTPClientError,
                                      file: StaticString = #filePath,
                                      line: UInt = #line) async {
        let request = GetRequestMock()
        let sut = URLSessionHttpClient()
        
        let response = makeHTTPURLResponse(statusCode: statusCode)
        URLProtocolStub.stub(data: nil, response: response, error: nil)
        
        do {
            _ = try await sut.perform(request)
            XCTFail("Expected error to be thrown", file: file, line: line)
        } catch let error as HTTPClientError {
            XCTAssertEqual(error, expectedError, file: file, line: line)
        } catch {
            XCTFail("Expected HTTPClientError, got \(error)", file: file, line: line)
        }
    }
    
    private func assertForURLError(with errorCode: URLError.Code,
                                   expectedError: HTTPClientError,
                                   file: StaticString = #filePath,
                                   line: UInt = #line) async {
        let request = GetRequestMock()
        let sut = URLSessionHttpClient()
        
        let urlError = URLError(errorCode)
        URLProtocolStub.stub(data: nil, response: nil, error: urlError)
        
        do {
            _ = try await sut.perform(request)
            XCTFail("Expected error to be thrown", file: file, line: line)
        } catch let error as HTTPClientError {
            XCTAssertEqual(error, expectedError, file: file, line: line)
        } catch {
            XCTFail("Expected HTTPClientError, got \(error)", file: file, line: line)
        }
    }
}

func makeError() -> NSError {
    return NSError(domain: "any error", code: 0)
}

func makeValidData() -> Data {
    return Data("{ \"id\": 1 }".utf8)
}

func makeHTTPURLResponse(statusCode: Int = 200, url: URL = URL(string: "https://a-url.com/path")!) -> HTTPURLResponse {
    return HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
}

struct GetRequestMock: HTTPRequest {
    var host: String = "a-url.com"
    var path: String = "/path"
    var method: HTTPMethod = .get
    var headers: [String: String] = [:]
    var body: HTTPBody = .empty()
    var url: URL {
        URL(string: "https://" + host + path)!
    }
}

private class URLProtocolStub: URLProtocol {
    private static var stub: Stub?
    private static var requestObserver: ((URLRequest) -> Void)?
    private(set) static var requestsCount: Int = 0
    
    private struct Stub {
        let data: Data?
        let response: URLResponse?
        let error: Error?
    }
    
    static func stub(data: Data?, response: URLResponse?, error: Error?) {
        stub = Stub(data: data, response: response, error: error)
    }
    
    static func observeRequest(observer: @escaping (URLRequest) -> Void) {
        requestObserver = observer
    }
    
    static func startInterceptingRequests() {
        URLProtocol.registerClass(URLProtocolStub.self)
    }
    
    static func stopInterceptingRequests() {
        URLProtocol.unregisterClass(URLProtocolStub.self)
        stub = nil
        requestObserver = nil
        requestsCount = 0
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    override func startLoading() {
        URLProtocolStub.requestsCount += 1
        
        if let requestObserver = URLProtocolStub.requestObserver {
            requestObserver(request)
        }
        
        if let stub = URLProtocolStub.stub {
            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
                return
            }
        }
        
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
}
