//: Playground - noun: a place where people can play

import DBNetworkStack
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true
let url: URL! = URL(string: "https://httpbin.org")
let baseURLKey = "httpBin"

let networkAccess = URLSession(configuration: .default)
let networkService = NetworkService(networkAccess: networkAccess, endPoints: [baseURLKey: url])
let request = NetworkRequest(path: "/", baseURLKey: baseURLKey)
let resource = Resource(request: request, parse: { String(data: $0, encoding: .utf8) })

networkService.request(resource, onCompletion: { htmlText in
    print(htmlText)
    }, onError: { error in
        //Handle errors
})
