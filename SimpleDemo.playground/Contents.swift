import DBNetworkStack
import PlaygroundSupport

//Setup Playground environment
PlaygroundPage.current.needsIndefiniteExecution = true
URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)

//Prepare NetworkAccess & NetworkService
let networkAccess = URLSession(configuration: .default)
let networkService = BasicNetworkService(networkAccess: networkAccess)

//Create a Resource with a given URLRequest and parsing
let url: URL! = URL(string: "https://bahn.de")
let request = URLRequest(path: "p/view/index.shtml", baseURL: url)
let resource = Resource(request: request, parse: { String(data: $0, encoding: .utf8) })

networkService.request(resource, onCompletion: { htmlText in
    print(htmlText)
    }, onError: { error in
        print(error)
})
