//: Playground - noun: a place where people can play

import DBNetworkStack
import XCPlayground

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

let url: NSURL! = NSURL(string: "https://httpbin.org")
let baseURLKey = "httpBin"

let networkAccess = NSURLSession(configuration: .defaultSessionConfiguration())
let networkService = NetworkService(networkAccess: networkAccess, endPoints: [baseURLKey: url])

struct IPOrigin {
    let ipAdress: String
}

extension IPOrigin: JSONMappable {
    init(object: Dictionary<String, AnyObject>) throws {
        guard let ipAdress = object["origin"] as? String else {
            throw DBNetworkStackError.SerializationError(description: "", data: nil)
        }
        self.ipAdress = ipAdress
    }
}

let request = NetworkRequest(path: "/ip", baseURLKey: baseURLKey)
let ressource = JSONRessource<IPOrigin>(request: request)

networkService.request(ressource, onCompletion: { origin in
    print(origin)
    }, onError: { error in
        //Handle errors
})
