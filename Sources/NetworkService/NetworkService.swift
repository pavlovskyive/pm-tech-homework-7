import Foundation

public struct NetworkService {
    
    private var successfulStatusCodes = 200..<300
    private var defaultHeaders: [String: String]
    
    public init(defaultHeaders: [String: String] = [:]) {
        self.defaultHeaders = defaultHeaders
    }
}

public extension NetworkService {
    
    mutating func setSuccessfulStatusCodes(_ range: Range<Int>) {
        
        let lowerBound = range.lowerBound >= 100 ? range.lowerBound : 100
        let upperBound = range.upperBound <= 600 ? range.upperBound : 600
        
        successfulStatusCodes = lowerBound..<upperBound
    }
    
}

extension NetworkService {
    
    func createRequest(resource: Resource) -> URLRequest {
        
        var request = URLRequest(url: resource.url)
        
        request.httpMethod = resource.method.rawValue
        
        let headers = defaultHeaders.merging(resource.headers,
                                             uniquingKeysWith: { (_, new) in new })
        request.allHTTPHeaderFields = headers
        
        request.httpBody = resource.body
        
        return request
    }
    
    func executeRequest(request: URLRequest,
                        completion: @escaping (Result<Data, NetworkError>) -> ()) {
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                completion(.failure(.dataTaskError(error)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                
                completion(.failure(.responseError))
                return
            }
            
            let statusCode = httpResponse.statusCode
            
            guard successfulStatusCodes.contains(statusCode) else {
                
                completion(.failure(.badStatusCode(statusCode)))
                return
            }

            guard let data = data else {

                completion(.failure(.badData))
                return
            }

            completion(.success(data))
        }

        task.resume()
    }
}
