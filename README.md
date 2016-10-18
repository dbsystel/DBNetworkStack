# DBNetworkStack

[![Build Status](https://travis-ci.com/lightsprint09/DBNetworkStackTemp.svg?token=DoSuqFLfFsZgTxGUxHry&branch=feature/cross-plattorm-project)](https://travis-ci.com/lightsprint09/DBNetworkStackTemp)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) 


DBNetworkStack is a network abstraction for fetching request and mapping them to model objects.

         | Main Features
---------|---------------
🛡 | Typed network ressources
&#127968; | Protocol oriented architecture
🔀| Exchangeable implementations
🚄 | Extendable API
&#9989; | Fully unit tested

The idea behind this project comes from this [talk.objc.io article](https://talk.objc.io/episodes/S01E01-networking).

## Basic Demo
Lets say you want to fetch a ``html`` string.

First you have to create a service, by providing a networkaccess. You can use NSURLSession out of the box or provide your own custom solution by implementing  ```NetworkAccessProviding```. In addition you need to register baseURLs for request mapping. This gives you the flexability to change your baseURLs very easyly when your envionment changes.

```swift
let url = NSURL(string: "https://httpbin.org")!
let baseURLKey = "httpBin"

let networkAccess = NSURLSession(configuration: .defaultSessionConfiguration())
let networkService = NetworkService(networkAccess: networkAccess, endPoints: [baseURLKey: url])
```


## Installation

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

Specify the following in your `Cartfile`:

```ogdl
github "dbsystel/dbnetworkstack" ~> 0.1
```

