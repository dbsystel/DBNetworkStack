# DBNetworkStack

[![Build Status](https://travis-ci.org/dbsystel/DBNetworkStack.svg?branch=develop)](https://travis-ci.org/dbsystel/DBNetworkStack)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![codecov](https://codecov.io/gh/dbsystel/DBNetworkStack/branch/develop/graph/badge.svg)](https://codecov.io/gh/dbsystel/DBNetworkStack)

|           | Main Features                  |
| --------- | ------------------------------ |
| 🛡        | Typed network resources        |
| &#127968; | Protocol oriented architecture |
| 🔀        | Exchangeable implementations   |
| 🚄        | Extendable API                 |
| 🎹        | Composable Features            |
| &#9989;   | Fully unit tested              |

The idea behind this project comes from this [talk.objc.io article](https://talk.objc.io/episodes/S01E01-networking).

## Basic Demo
Lets say you want to fetch a ``html`` string.

First you have to create a service, by providing a network access. You can use NSURLSession out of the box or provide your own custom solution by implementing  ```NetworkAccessProviding```. In addition you need to register baseURLs endpoints for request mapping. This gives you the flexibility to change your endpoints very easily when your environment changes.

```swift

let url = NSURL(string: "https://httpbin.org")!
let baseURLKey = "httpBin"

let networkAccess = NSURLSession(configuration: .defaultSessionConfiguration())
let networkService = NetworkService(networkAccess: networkAccess, endPoints: [baseURLKey: url])

```

Create a resource with a request to fetch your data.

```swift

let request = NetworkRequest(path: "/", baseURLKey: baseURLKey)
let resource = Resource(request: request, parse: { String(data: $0, encoding: NSUTF8StringEncoding) })

```
Request your resource and handle the response
```swift
networkService.request(resource, onCompletion: { htmlText in
    print(htmlText)
}, onError: { error in
        //Handle errors
})

```

## JSON Mapping Demo
```swift
struct IPOrigin {
    let ipAddress: String
}

extension IPOrigin: JSONMappable {
    init(object: Dictionary<String, AnyObject>) throws {
       /// Do your mapping
    }
}

let request = NetworkRequest(path: "/ip", baseURLKey: baseURLKey)
let resource = JSONResource<IPOrigin>(request: request)

networkService.request(resource, onCompletion: { origin in
    print(origin)
}, onError: { error in
        //Handle errors
})
```

## Extendability
The following example outlines how to extend DBNetworkStack to support XML response models:

```swift
protocol XMLMappable {
    init(object: Dictionary<String, AnyObject>) throws
}

struct XMLResource<T : XMLMappable> : ResourceModeling {
    let request: NetworkRequestRepresening
    
    init(request: NetworkRequestRepresening) {
        self.request = request
    }
    
    var parse: (data: NSData) throws -> T {
        return { data in
            let xmlObject = // Your data to xml object conversion
            try! T(object: xmlObject) as T
        }
    }
}
```
```XMLMappable``` defines the protocol, response model objects must conform to. The model class conforming to this protocol is responsible to convert a generic representation of the model into it’s specialized form.
```XMLResource<T : XMLMappable>``` defines a resource based on a given ```XMLMappable``` model. The parse function is responsible of converting raw response data to a generic representation.


## Protocol oriented architecture / Exchangability

The following table shows all the protocols and their default implementations.

| Protocol                         | Default Implementation |
| -------------------------------- | ---------------------- |
| ```NetworkAccessProviding```     | ```NSURLSession```     |
| ```NetworkServiceProviding```    | ```NetworkService```   |
| ```NetworkRequestRepresenting``` | ```NetworkRequest```   |
| ```NetworkTaskRepresenting```    | ```NSURLSessionTask``` |
| ```ResourceModelling```          | ```Resource<Model>```  |

## Composable Features

| Class                         | Feature |
| -------------------------------- | ---------------------- |
| ```RetryNetworkService```        | Retrys requests after a given delay when an error meets given criteria. |
| ```ModifyRequestNetworkService```        | Modify matching requests. Can be used to add auth tokens or API Keys  |

## Requirements

- iOS 9.0+ / macOS 10.10+ / tvOS 9.0+ / watchOS 2.0+
- Xcode 8.0+
- Swift 3.0

## Installation

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

Specify the following in your `Cartfile`:

```ogdl
github "dbsystel/dbnetworkstack" ~> 0.3
```
## Contributing
Feel free to submit a pull request with new features, improvements on tests or documentation and bug fixes. Keep in mind that we welcome code that is well tested and documented.

## Contact
Lukas Schmidt ([Mail](mailto:lukas.la.schmidt@deutschebahn.com), [@lightsprint09](https://twitter.com/lightsprint09)), 
Christian Himmelsbach ([Mail](mailto:christian.himmelsbach@deutschebahn.com))

## License
DBNetworkStack is released under the MIT license. See LICENSE for details.
