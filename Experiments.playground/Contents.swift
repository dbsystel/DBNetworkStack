//: Playground - noun: a place where people can play

import UIKit
import DBNetworkStack
import XCPlayground
//import Alamofire

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

struct Formular {
    let text: String
    let image: UIImage
}

struct Report {
    init(data: NSData) throws {
        
    }
}

// Mock

struct MyNetworkTask: NetworkTask {
    func cancel() {
        
    }
    func resume() {
        
    }
    func suspend() {
        
    }
    
    var progress = NSProgress()
}
struct UploadAccessMock: MultipartFormDataUploadAccessProviding {
    func upload(request: NetworkRequestRepresening, relativeToBaseURL: NSURL, multipartFormData: (MultipartFormDataRepresenting) -> (), encodingMemoryThreshold: UInt64, callback: (NSData?, NSHTTPURLResponse?, NSError?) -> (), onNetworkTaskCreation: DBNetworkTaskCreationCompletionBlock?) {
        
        dispatch_async(dispatch_get_main_queue()) {
            onNetworkTaskCreation?(MyNetworkTask())
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2.0)*Int64(NSEC_PER_SEC)), dispatch_get_main_queue(), {
                callback(NSData(),nil,nil)
            })
        }
        
    }
}

enum APIs: String, BaseURLKey {
    case BFA
    
    var name: String {
        return rawValue
    }
    var url: NSURL {
        return NSURL(string: "https://dbbfa.herokuapp.com/")!
    }
}

let formular = Formular(text: "hallo", image: UIImage())
let ressource = MultipartFormDataRessource(
    request: NetworkRequest(path: "", baseURLKey: APIs.BFA),
    parse: { try Report(data: $0) },
    encodingMemoryThreshold: 1000,
    encodeInMultipartFormData: {multipartFormData in
    multipartFormData.appendBodyPart(data: formular.text.dataUsingEncoding(NSUTF8StringEncoding)!, name: "text")
    multipartFormData.appendBodyPart(data: UIImagePNGRepresentation(formular.image)!, name: "image")
})
let baseURL = APIs.BFA
let service = MultipartFormDataUploadService(
    uploadAccess: UploadAccessMock(),
    endPoints: [baseURL.name:baseURL.url]
)

service.upload(ressource, onCompletion: { report in
    print("Nicey")
}, onError: { error in
    print("Error: \(error)")
}, onNetworkTaskCreation: { task in
    print("Task created")
    
})


// Alamofire Implmentation
//extension Alamofire.MultipartFormData: MultipartFormDataRepresenting {}
//extension Alamofire.Request: NetworkTask {}
//
//class AlamofireUploadAccess: MultipartFormDataUploadAccessProviding {
//    func upload(request: NetworkRequestRepresening, relativeToBaseURL: NSURL, multipartFormData: (MultipartFormDataRepresenting) -> (), encodingMemoryThreshold: UInt64, callback: (NSData?, NSHTTPURLResponse?, NSError?) -> (), onNetworkTaskCreation: (NetworkTask) -> ()) {
//        Alamofire.upload(
//            .POST,
//            NSURL(string: request.path, relativeToURL: relativeToBaseURL)!,
//            multipartFormData: multipartFormData,
//            encodingCompletion: { encodingResult in
//                switch encodingResult {
//                case .Success(let upload, _, _):
//                    onNetworkTaskCreation(upload)
//                    upload.response(completionHandler: { request, response, data, error in
//                        callback(data, response, error)
//                    })
//                case .Failure(let encodingError):
//                    //TODO ErrorHandling
//                    callback(nil, nil, NSError(code: .BadRequest, 
