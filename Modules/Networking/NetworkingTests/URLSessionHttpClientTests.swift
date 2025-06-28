import XCTest
import Foundation
import NetworkingInterface
import NetworkingTesting
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
        let request = RequestMock()
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
        let request = RequestMock()
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
        let request = RequestMock()
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
        let request = RequestMock()
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
        let request = RequestMock()
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
