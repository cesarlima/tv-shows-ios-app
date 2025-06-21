import XCTest
import Foundation
@testable import Networking

final class URLSessionHttpClient {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func perform(_ request: HTTPRequest) async throws {
        (_, _) = try await session.data(for: request.asURLRequest())
    }
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
