# DBNetworkStack

[![Build Status](https://travis-ci.org/dbsystel/DBNetworkStack.svg?branch=develop)](https://travis-ci.org/dbsystel/DBNetworkStack)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
 [![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![Version](https://img.shields.io/cocoapods/v/DBNetworkStack.svg?style=flat)](http://cocoapods.org/pods/DBNetworkStack)
[![Swift Version](https://img.shields.io/badge/Swift-3.0--3.1-F16D39.svg?style=flat)](https://developer.apple.com/swift)
[![Swift Version](https://img.shields.io/badge/Linux-3.1-4BC51D.svg?style=flat)](https://developer.apple.com/swift)
[![codecov](https://codecov.io/gh/dbsystel/DBNetworkStack/branch/develop/graph/badge.svg)](https://codecov.io/gh/dbsystel/DBNetworkStack)

|           | Main Features                  |
| --------- | ------------------------------ |
| 🛡        | Typed network resources        |
| &#127968; | Value oriented architecture |
| 🔀        | Exchangeable implementations   |
| 🚄        | Extendable API                 |
| 🎹        | Composable Features            |
| &#9989;   | Fully unit tested              |

The idea behind this project comes from this [talk.objc.io article](https://talk.objc.io/episodes/S01E01-networking).

## Basic Demo
Lets say you want to fetch a ``html`` string.

First you have to create a service, by providing a network access. You can use URLSession out of the box or provide your own custom solution by implementing  ```NetworkAccessProviding```.

```swift

let networkAccess = URLSession(configuration: .default)
let networkService = NetworkService(networkAccess: networkAccess)

```

Create a resource with a request to fetch your data.

```swift

let url = URL(string: "https://httpbin.org")!
let request = URLRequest(path: "/", baseURL: url)
let resource = Resource(request: request, parse: { String(data: $0, encoding: .utf8) })

```
Request your resource and handle the response
```swift
networkService.request(resource, onCompletion: { htmlText in
    print(htmlText)
}, onError: { error in
    //Handle errors
})

```

## Loade types conforming to `Decodable`
```swift
struct IPOrigin: Decodable {
    let origin: String
}

let url: URL! = URL(string: "https://www.httpbin.org")
let request = URLRequest(path: "ip", baseURL: url)

let resource = Resource<IPOrigin>(request: request, decoder: JSONDecoder())

networkService.request(resource, onCompletion: { origin in
    print(origin)
}, onError: { error in
    //Handle errors
})
```

## Extendability
The following example outlines how to extend DBNetworkStack to support the imaginary type `XMLDocument`:

```swift
extension Resource where Model: XMLDocument {
    public init(request: URLRequestConvertible) {
        self.init(request: request, parse: { try XMLDocument(data: $0 })
    }
}
```

You are now able to call:
```swift
let xmlDocument = Resource<XMLDocument>(request: someRequest)
```


## Protocol oriented architecture / Exchangability

The following table shows all the protocols and their default implementations.

| Protocol                         | Default Implementation |
| -------------------------------- | ---------------------- |
| ```NetworkAccessProviding```     | ```URLSession```     |
| ```NetworkServiceProviding```    | ```NetworkService```   |
| ```NetworkRequestRepresenting``` | ```NetworkRequest```   |
| ```NetworkTaskRepresenting```    | ```URLSessionTask``` |

## Composable Features

| Class                         | Feature |
| -------------------------------- | ---------------------- |
| ```RetryNetworkService```        | Retrys requests after a given delay when an error meets given criteria. |
| ```ModifyRequestNetworkService```        | Modify matching requests. Can be used to add auth tokens or API Keys  |

## Requirements

- iOS 9.0+ / macOS 10.10+ / tvOS 9.0+ / watchOS 2.0+
- Xcode 9.0+
- Swift 3.2/Swift4.0

## Installation

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

Specify the following in your `Cartfile`:

```ogdl
github "dbsystel/dbnetworkstack" ~> 0.5
```

### CocoaPods

`pod "DBNetworkStack"`

## Contributing
Feel free to submit a pull request with new features, improvements on tests or documentation and bug fixes. Keep in mind that we welcome code that is well tested and documented.

## Contact
Lukas Schmidt ([Mail](mailto:lukas.la.schmidt@deutschebahn.com), [@lightsprint09](https://twitter.com/lightsprint09)), 
Christian Himmelsbach ([Mail](mailto:christian.himmelsbach@deutschebahn.com))

## License
DBNetworkStack is released under the MIT license. See LICENSE for details.
