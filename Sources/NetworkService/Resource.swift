//
//  Resource.swift
//  
//
//  Created by Vsevolod Pavlovskyi on 06.03.2021.
//

import Foundation

/// Resource holds all the necessary information for performing a request.
/// Interface for working with NetworkService.
public struct Resource {
    
    var method: HTTPMethod
    var url: URL
    var body: Data?
    var headers: [String: String]
    
    public init(method: HTTPMethod,
         url: URL,
         body: Data? = nil,
         headers: [String: String] = [:]) {
        
        if method == .get && body != nil {
            fatalError("GET method must not have a body")
        }
        
        self.method = method
        self.url = url
        self.body = body
        self.headers = headers
    }

}

public extension Resource {
    
    /// Performs request with decoding data.
    ///
    /// - Parameters:
    ///   - networkService: configured NetworkService instance, can be ommited (default configuration will be used).
    ///   - type: expected response type.
    ///   - completion: handle response.
    /// - Returns: Void
    func performRequest<T: Decodable>(with networkService: NetworkService = NetworkService(),
                                      decodingTo type: T.Type,
                                      completion: @escaping (Result<T, NetworkError>) -> ()) {
        
        performRequest(with: networkService) { result in
            switch result {
            case .success(let data):
                decode(data: data, type: T.self, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Performs request without data decoding.
    ///
    /// - Parameters:
    ///   - networkService: configured NetworkService instance, can be ommited (default configuration will be used).
    ///   - completion: handle response.
    /// - Returns: Void
    func performRequest(with networkService: NetworkService = NetworkService(),
                        completion: @escaping (Result<Data, NetworkError>) -> ()) {
        
        let request = networkService.createRequest(resource: self)
        networkService.executeRequest(request: request, completion: completion)
    }

}

private extension Resource {
    
    /// Decode data to specified type.
    ///
    /// - Parameters:
    ///   - data: Data for decoding.
    ///   - type: Specified Decodable type.
    ///   - completion: Specified type Result handler.
    func decode<T: Decodable>(data: Data,
                              type: T.Type,
                              completion: @escaping(Result<T, NetworkError>) -> Void) {
        
        let decoder = JSONDecoder()
        
        do {
            let object = try decoder.decode(type, from: data)
            completion(.success(object))
        } catch {
            completion(.failure(.decodingError(error)))
        }
        
    }
    
}
