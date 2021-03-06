//
//  Resource.swift
//  
//
//  Created by Vsevolod Pavlovskyi on 06.03.2021.
//

import Foundation

public struct Resource {
    
    var method: HTTPMethod
    var url: URL
    var body: Data?
    var headers: [String: String]
    
    public init(method: HTTPMethod,
         url: URL,
         body: Data? = nil,
         headers: [String: String] = [:]) {
        
        self.method = method
        self.url = url
        self.body = body
        self.headers = headers
    }

}

public extension Resource {

    func performRequest<T: Decodable>(with networkService: NetworkService = NetworkService(),
                                      decodingTo type: T.Type,
                                      completion: @escaping (Result<T, NetworkError>) -> ()) {
        
        performRequest(with: networkService) { result in
            switch result {
            case .success(let data):
                data.decode(type: type) { result in
                    switch result {
                    case .success(let object):
                        completion(.success(object))
                    case .failure(let error):
                        completion(.failure(.decodingError(error)))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func performRequest(with networkService: NetworkService = NetworkService(),
                        completion: @escaping (Result<Data, NetworkError>) -> ()) {
        
        let request = networkService.createRequest(resource: self)
        networkService.executeRequest(request: request, completion: completion)
    }

}
