import XCTest
import Foundation
import NetworkingInterface
@testable import Networking

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
