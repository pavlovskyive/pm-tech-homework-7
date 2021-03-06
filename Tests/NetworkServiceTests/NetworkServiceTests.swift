import XCTest
@testable import NetworkService

final class NetworkServiceTests: XCTestCase {
    
    let resource = Resource(method: .post,
                            url: URL(string: "https://google.com")!,
                            body: "Sample".data(using: .utf8),
                            headers: ["overriding": "newValue"])
    
    func testRequestCreation() {
        
        let defaultHeaders = [
            "token": "token",
            "overriding": "startValue"
        ]
        
        let networkService = NetworkService(defaultHeaders: defaultHeaders)
        
        let request = networkService.createRequest(resource: resource)
        
        let assertingHeaders = [
            "token": "token",
            "overriding": "newValue"
        ]
        
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.url, URL(string: "https://google.com")!)
        XCTAssertEqual(request.httpBody, "Sample".data(using: .utf8))
        XCTAssertEqual(request.allHTTPHeaderFields, assertingHeaders)

    }
    
    func testSettingSuccessfulStatusCodes() {
        
        var networkService = NetworkService()
        
        let request = networkService.createRequest(resource: resource)
        
        networkService.executeRequest(request: request) { result in
            switch result {
            case .success(let data):
                XCTAssertNotNil(data)
            case .failure(_):
                XCTFail("Error thrown")
            }
        }
        
        networkService.setSuccessfulStatusCodes(300..<700)
        
        networkService.executeRequest(request: request) { result in
            switch result {
            case .success(_):
                XCTFail("No error thrown")
            case .failure(let error):
                XCTAssertEqual(error.localizedDescription, NetworkError.badStatusCode(200).localizedDescription)
            }
        }
        
        networkService.setSuccessfulStatusCodes(-200..<100)
        
        networkService.executeRequest(request: request) { result in
            switch result {
            case .success(_):
                XCTFail("No error thrown")
            case .failure(let error):
                XCTAssertEqual(error.localizedDescription, NetworkError.badStatusCode(200).localizedDescription)
            }
        }
    }

    static var allTests = [
        ("testRequestCreation", testRequestCreation),
        ("testSettingSuccessfulStatusCodes", testSettingSuccessfulStatusCodes),
    ]
}
