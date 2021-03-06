import Foundation


/// Actual network layer.
public struct NetworkService {
    
    /// Acceptable response status codes.
    /// Status codes which are not in specified range considered erroneous.
    private var successfulStatusCodes = 200..<300
    
    /// Defualt HTTPHeaders which will be added in every request.
    /// Overriden by per-request headers
    private var defaultHeaders: [String: String]
    
    /// Initializer
    /// - Parameter defaultHeaders: Defualt HTTPHeaders which will be added in every request.
    public init(defaultHeaders: [String: String] = [:]) {
        self.defaultHeaders = defaultHeaders
    }
}

public extension NetworkService {
    
    /// Set acceptable response status codes.
    /// Status codes which are not in specified range considered erroneous.
    /// By default its 200..<300
    ///
    /// - Parameter range: 100..<600
    mutating func setSuccessfulStatusCodes(_ range: Range<Int>) {
        
        let lowerBound = range.lowerBound >= 100 ? range.lowerBound : 100
        let upperBound = range.upperBound <= 600 ? range.upperBound : 600
        
        successfulStatusCodes = lowerBound..<upperBound
    }
    
}

extension NetworkService {
    
    /// Creates request from Resource instance
    ///
    /// - Parameter resource: Resource instance which holds the necessary information for performing a request.
    /// - Returns: Request that will be used by Resource interface for performing a network request.
    func createRequest(resource: Resource) -> URLRequest {
        
        var request = URLRequest(url: resource.url)
        
        request.httpMethod = resource.method.rawValue
        
        let headers = defaultHeaders.merging(resource.headers,
                                             uniquingKeysWith: { (_, new) in new })
        request.allHTTPHeaderFields = headers
        
        request.httpBody = resource.body
        
        return request
    }
    
    /// Executes request.
    /// 
    /// - Parameters:
    ///   - request: Configured URLRequest instance.
    ///   - completion: Data Result handler.
    /// - Returns: Void
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
