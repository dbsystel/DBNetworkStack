# DBNetworkStack

[![Build Status](https://travis-ci.com/lightsprint09/DBNetworkStack.svg?token=DoSuqFLfFsZgTxGUxHry&branch=develop)](https://travis-ci.com/lightsprint09/DBNetworkStack)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) 

         | Main Features
---------|---------------
🛡 | Typed network resources
&#127968; | Protocol oriented architecture
🔀| Exchangeable implementations
🚄 | Extendable API
&#9989; | Fully unit tested

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

## Requirements

- iOS 9.0+ / macOS 10.10+ / tvOS 9.0+ / watchOS 2.0+
- Xcode 8.0+
- Swift 3.0

## Installation

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

Specify the following in your `Cartfile`:

```ogdl
github "dbsystel/dbnetworkstack" ~> 0.1
```
## Contributing
Feel free to submit a pull request with new features, improvements on tests or documentation and bug fixes. Keep in mind that we welcome code that is well tested and documented.

## Contact
Lukas Schmidt ([Mail](mailto:lukas.la.schmidt@deutschebahn.com), [@lightsprint09](https://twitter.com/lightsprint09)), 
Christian Himmelsbach ([Mail](mailto:christian.himmelsbach@deutschebahn.com))

## License
DBNetworkStack is released under the MIT license. See LICENSE for details.
