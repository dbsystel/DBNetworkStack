//: Playground - noun: a place where people can play

import DBNetworkStack
import XCPlayground

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

let url = NSURL(string: "https://httpbin.org")!
let baseURLKey = "httpBin"

let networkAccess = NSURLSession(configuration: .defaultSessionConfiguration())
let networkService = NetworkService(networkAccess: networkAccess, endPoints: [baseURLKey: url])

struct IPOrigin {
    let ip: String
}

extension IPOrigin: JSONMappable {
    init(object: Dictionary<String, AnyObject>) throws {
        guard let ip = object["origin"] as? String else {
            throw DBNetworkStackError.SerializationError(description: "", data: nil)
        }
        self.ip = ip
    }
}

let request = NetworkRequest(path: "/ip", baseURLKey: baseURLKey)
let ressource = JSONRessource<IPOrigin>(request: request)

networkService.request(ressource, onCompletion: { htmlText in
    print(htmlText)
    }, onError: { error in
        //Handle errors
})

