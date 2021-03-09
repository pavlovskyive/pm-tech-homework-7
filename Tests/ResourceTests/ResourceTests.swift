import XCTest
@testable import NetworkService

final class ResourceTests: XCTestCase {
    
    let networkService = NetworkService()
    
    func testPerformRequest() {
        let resource = Resource(method: .get,
                                url: URL(string: "https://jsonplaceholder.typicode.com/posts/1")!)
        
        resource.performRequest { result in
            switch result {
            case .success(let data):
                XCTAssertNotNil(data)
            case .failure(_):
                XCTFail("Error thrown")
            }
        }
    }
    
    func testPerformRequestDecoding() {
        let resource = Resource(method: .get,
                                url: URL(string: "https://jsonplaceholder.typicode.com/posts/1")!)
        
        struct Post: Codable {
            var id: Int
            var title: String
            var body: String
            var userId: Int
        }
        
        resource.performRequest(decodingTo: Post.self) { result in
            switch result {
            case .success(_):
                break;
            case .failure(_):
                XCTFail("Error thrown")
            }
        }
    }
    
    static var allTests = [
        ("testPerformRequest", testPerformRequest),
        ("testPerformRequestDecoding", testPerformRequestDecoding),
    ]
}
