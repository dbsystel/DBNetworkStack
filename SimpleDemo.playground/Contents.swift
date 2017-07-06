//: Playground - noun: a place where people can play

import DBNetworkStack
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

let networkAccess = URLSession(configuration: .default)
let networkService = NetworkService(networkAccess: networkAccess)

let url: URL! = URL(string: "https://httpbin.org")
let request = URLRequest(path: "/", baseURL: url)
let resource = Resource(request: request, parse: { String(data: $0, encoding: .utf8) })

networkService.request(resource, onCompletion: { htmlText in
    print(htmlText)
    }, onError: { _ in
        //Handle errors
})
