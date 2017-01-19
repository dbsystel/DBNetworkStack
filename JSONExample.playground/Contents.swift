//: Playground - noun: a place where people can play

import DBNetworkStack
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

let url: URL! = URL(string: "https://httpbin.org")
let baseURLKey = "httpBin"

let networkAccess = URLSession(configuration: .default)
let networkService = NetworkService(networkAccess: networkAccess, endPoints: [baseURLKey: url])

struct IPOrigin {
    let ipAdress: String
}

extension IPOrigin: JSONMappable {
    init(object: Dictionary<String, AnyObject>) throws {
        guard let ipAdress = object["origin"] as? String else {
            throw DBNetworkStackError.serializationError(description: "", data: nil)
        }
        self.ipAdress = ipAdress
    }
}

let request = NetworkRequest(path: "/ip", baseURLKey: baseURLKey)
let resource = JSONResource<IPOrigin>(request: request)

networkService.request(resource, onCompletion: { origin in
    print(origin)
    }, onError: { _ in
        //Handle errors
})
