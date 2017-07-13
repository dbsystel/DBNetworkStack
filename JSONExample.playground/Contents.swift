//: Playground - noun: a place where people can play

import DBNetworkStack
import PlaygroundSupport

//Setup Playground environment
PlaygroundPage.current.needsIndefiniteExecution = true
URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)

//Prepare NetworkAccess & NetworkService
let networkAccess = URLSession(configuration: .default)
let networkService = NetworkService(networkAccess: networkAccess)

struct IPOrigin {
    let ipAdress: String
}

extension IPOrigin: JSONMappable {
    init(object: Dictionary<String, Any>) throws {
        guard let ipAdress = object["origin"] as? String else {
            throw DBNetworkStackError.serializationError(description: "", data: nil)
        }
        self.ipAdress = ipAdress
    }
}

let url: URL! = URL(string: "https://www.httpbin.org")
let request = URLRequest(path: "ip", baseURL: url)
let resource = JSONResource<IPOrigin>(request: request)

networkService.request(resource, onCompletion: { origin in
    print(origin)
    }, onError: { error in
        print(error)
})
