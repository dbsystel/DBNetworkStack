//: Playground - noun: a place where people can play

import UIKit
import DBNetworkStack
import XCPlayground
//import Alamofire
//
//XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//
//protocol MultiparRessource: RessourceModeling {
//    var encodeInMultipartFormData: MultipartFormDataRepresenting -> Void { get }
//    var encodingMemoryThreshold: UInt64 { get }
//}
//
//extension Alamofire.MultipartFormData: MultipartFormDataRepresenting {}
//extension Alamofire.Request: NetworkTask {}
//
//class AlamofireUploadAccess: UploadAccessProviding {
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
//                    callback(nil, nil, NSError(code: .BadRequest, userInfo: ["err": ""]))
//                }
//            })
//    }
//}
//
//
//
//protocol UploadAccessProviding {
//    func upload(
//                request: NetworkRequestRepresening, relativeToBaseURL: NSURL,
//                multipartFormData: (MultipartFormDataRepresenting) -> (),
//                encodingMemoryThreshold: UInt64,
//                callback: (NSData?, NSHTTPURLResponse?, NSError?) -> (), onNetworkTaskCreation: (NetworkTask) -> ())
//}
//
//protocol MultiUploadPoviderServiceProviding {
//    func upload<T: MultiparRessource>(ressource: T, onCompletion: (T.Model) -> (), onError: (NSError) -> (), onNetworkTaskCreation: (NetworkTask) -> ())
//}
//
//class MultiPartUploadPoviderService: MultiUploadPoviderServiceProviding, NetworkResponseProcessing {
//    let uploadAccess: UploadAccessProviding
//    
//    init(uploadAccess: UploadAccessProviding) {
//        self.uploadAccess = uploadAccess
//    }
//    
//    func upload<T: MultiparRessource>(ressource: T, onCompletion: (T.Model) -> (), onError: (NSError) -> (), onNetworkTaskCreation: (NetworkTask) -> ()) {
//        //TODO: Build baseURL
//        let baseURL = NSURL()
//        uploadAccess.upload(ressource.request, relativeToBaseURL: baseURL, multipartFormData: ressource.encodeInMultipartFormData, encodingMemoryThreshold: ressource.encodingMemoryThreshold, callback: { data, response, error in
//            do {
//                let parsed = try self.process(response: response, ressource: ressource, data: data, error: error)
//                dispatch_async(dispatch_get_main_queue()) {
//                    onCompletion(parsed)
//                }
//            } catch let error as NSError {
//                dispatch_async(dispatch_get_main_queue()) {
//                    return onError(error)
//                }
//            }
//        }, onNetworkTaskCreation: onNetworkTaskCreation)
//    }
//}




