//: Playground - noun: a place where people can play

import UIKit
import DBNetworkStack
import XCPlayground

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

public struct Station {
    public let id: String
    public let name: String
}

extension Station: JSONMappable {
    public init(object: [String: AnyObject]) throws {
        id = object["id"] as! String
        name = object["name"] as! String
    }
}

enum BaseURLs: String, BaseURLKey {
    case BFA
    case BahnDE
    
    var name: String {
        return rawValue
    }
    
    var url: NSURL {
        switch self {
        case BFA:
            return NSURL(string: "https://dbbfa.herokuapp.com/")!
        case .BahnDE:
            return NSURL(string: "https://www.bahn.de")!
        }
    }
}

let baseURL = BaseURLs.BFA
let networkAccess = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
let service = NetworkService(networkAccess: networkAccess, endPoints: [baseURL.name: baseURL.url])

let searchTerm = "Frankfurt"

let path = ("/v1/station/search?term=" + searchTerm)
let request = NetworkRequest(path: path, baseURLKey: baseURL)
let ressource = JSONArrayRessource<Station>(request: request)

service.fetch(ressource, onCompletion: { station in
        print(station)
    }, onError: { error in
        print(error)
})
