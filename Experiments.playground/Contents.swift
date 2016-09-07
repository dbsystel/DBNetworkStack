//: Playground - noun: a place where people can play

import UIKit
import DBNetworkStack
import XCPlayground

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

protocol MultiparRessource: RessourceModeling {
    var encodeInMultipartFormData: MultipartFormDataRepresenting -> Void { get }
    var encodingMemoryThreshold: UInt64 { get }
}



protocol UploadAccessProviding {
    func upload(
                request: NetworkRequestRepresening, relativeToBaseURL: NSURL,
                multipartFormData: (MultipartFormDataRepresenting) -> (),
                encodingMemoryThreshold: UInt64,
                callback: (NSData?, NSHTTPURLResponse?, NSError?) -> ()) -> NetworkTask

}

protocol MultiUploadPoviderServiceProviding {
    func upload<T: MultiparRessource>(ressource: T, onCompletion: (T.Model) -> (), onError: (NSError) -> ()) -> NetworkTask
}

class MultiUploadPoviderService: MultiUploadPoviderServiceProviding, NetworkResponseProcessing {
    let uploadAccess: UploadAccessProviding
    
    init(uploadAccess: UploadAccessProviding) {
        self.uploadAccess = uploadAccess
    }
    
    func upload<T: MultiparRessource>(ressource: T, onCompletion: (T.Model) -> (), onError: (NSError) -> ()) -> NetworkTask {
        //TODO: Build baseURL
        let baseURL = NSURL()
        return uploadAccess.upload(ressource.request, relativeToBaseURL: baseURL, multipartFormData: ressource.encodeInMultipartFormData, encodingMemoryThreshold: ressource.encodingMemoryThreshold, callback: { data, response, error in
            do {
                let parsed = try self.process(response: response, ressource: ressource, data: data, error: error)
                dispatch_async(dispatch_get_main_queue()) {
                    onCompletion(parsed)
                }
            } catch let error as NSError {
                dispatch_async(dispatch_get_main_queue()) {
                    return onError(error)
                }
            }
        })
    }
}




