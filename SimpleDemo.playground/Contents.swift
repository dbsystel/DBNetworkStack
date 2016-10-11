//: Playground - noun: a place where people can play

import UIKit
import DBNetworkStack
import XCPlayground

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

let url = NSURL(string: "https://httpbin.org")!
let baseURLKey = "httpBin"

let networkAccess = NSURLSession(configuration: .defaultSessionConfiguration())
let networkService = NetworkService(networkAccess: networkAccess, endPoints: [baseURLKey: url])

let request = NetworkRequest(path: "/", baseURLKey: baseURLKey)
let ressource = Ressource(request: request, parse: { String(data: $0, encoding: NSUTF8StringEncoding) })

networkService.request(ressource, onCompletion: { htmlText in
    print(htmlText)
    }, onError: { error in
        //Handle errors
})
