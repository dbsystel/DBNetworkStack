//: Playground - noun: a place where people can play

import Foundation
import DBNetworkStack
import Alamofire
import XCPlayground
import JSONCodable

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

public struct Station {
    public let id: String
    public let name: String
}

extension Station: JSONDecodable, JSONMappable {
    public init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        id = try decoder.decode("id")
        name = try decoder.decode("name")
    }
}

enum BaseURLs: String, BaseURLKey {
    case BFA
    case IRIS
    case RIS
    case BahnDE
    
    var name: String {
        return rawValue
    }
    
    var url: NSURL {
        switch self {
        case BFA:
            return NSURL(string: "https://dbbfa.herokuapp.com/")!
        case IRIS:
            return NSURL()
        case RIS:
            return NSURL()
        case .BahnDE:
            return NSURL(string: "https://www.bahn.de")!
        }
    }
}

let baseURL = BaseURLs.BFA
let service = AlamofireNetworkService(requestFunction: Alamofire.request, endPoints: [baseURL.name: baseURL.url])

let searchTerm = "Frankfurt"

let path = ("/v1/station/search?term=" + searchTerm).stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!
let request = NetworkRequest(path: path, baseURLKey: BaseURLs.BFA)
let ressource = JSONArrayRessource<Station>(request: request)

service.fetch(ressource, onCompletion: { station in
    print(station)
    }, onError: { error in
        print(error)
})
