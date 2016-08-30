//: Playground - noun: a place where people can play

import Foundation
import DBNetworkStack
import Alamofire
import XCPlayground

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

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
            return NSURL()
        case IRIS:
            return NSURL()
        case RIS:
            return NSURL()
        case .BahnDE:
            return NSURL(string: "https://www.bahn.de")!
        }
    }
}



let baseURL = BaseURLs.BahnDE
let service = AlamofireNetworkService(requestFunction: Alamofire.request, endPoints: [baseURL.name: baseURL.url])

//Different Place
var request = NetworkRequest(path: "/p/view/index.shtml", baseURLKey: baseURL)
let ressource = Ressource<String?>(request: request, parse: { String(data: $0, encoding: NSUTF8StringEncoding)})

service.fetch(ressource, onCompletion: { htmlString in
    print(htmlString)
    }, onError: { error in
})