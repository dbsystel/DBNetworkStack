//: Playground - noun: a place where people can play

import DBNetworkStack
import PlaygroundSupport

//Setup Playground environment
PlaygroundPage.current.needsIndefiniteExecution = true
URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)

//Prepare NetworkAccess & NetworkService
let networkAccess = URLSession(configuration: .default)
let networkService = BasicNetworkService(networkAccess: networkAccess)

struct IPOrigin: Decodable {
    let origin: String
}

let url: URL! = URL(string: "https://www.httpbin.org")
let request = URLRequest(path: "ip", baseURL: url)

let resource = Resource<IPOrigin>(request: request, decoder: JSONDecoder())

networkService.request(resource, onCompletionWithResponse: { origin, response in
    print(origin, response)
}, onError: { error in
    print(error)
})
