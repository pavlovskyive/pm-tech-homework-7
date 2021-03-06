# Network Service

HTTP networking library written in Swift.

- [Features](#features)
- [Usage](#usage)

## Features

- [x] Supports following HTTP methods: GET, POST, PUT, DELETE.
- [x] Includes default validation that can be overriden by user.
- [x] Convenient interface based on Resource objects which store all the necessary information for performing a request and are used for executing a network request.
- [x] Allows specification of default HTTP headers and per-request HTTP headers.

## Usage

### Configuring NetworkService

User can configure NetworkService instance changing its default headers and validation settings.


```swift
let defaultHeaders = [
    "token": token,
]

let networkService = NetworkService(defaultHeaders: defaultHeaders)

networkService.setSuccessfulStatusCodes(100..<600)
```

### Creating a Resource

Necessary parameters for Resource objects are **method** -- *HTTPMethod enum case* and **url** -- *URL on which request will be sent*. User can also specify per-request **headers** -- *[String: String] dictionary* and request **body** -- *Data object*.

```swift
let resource = Resource(method: .post,
                        url: url,
                        body: body,
                        headers: headers)
```

### Performing a request

User can perform request from calling a designated method on created Resource instance.

NetworkService parameter can be omitted, default NetworkService specification will be used.

Perform request and decode data:

```swift
resource.performRequest(with: networkService, decodingTo: Post.self) { result in
    switch result {
    case .success(let post):
        print(post)
    case .failure(let error):
        print(error)
    }
}
```

Perform request without data decoding:

```swift
resource.performRequest(with: networkService) { result in
    switch result {
    case .success(let data):
        print(data)
    case .failure(let error):
        print(error)
    }
}
```

