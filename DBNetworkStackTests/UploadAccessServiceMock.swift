//
//  UploadAccessServiceMock.swift
//  DBNetworkStack
//
//  Created by Christian Himmelsbach on 29.09.16.
//  Copyright © 2016 DBSystel. All rights reserved.
//

import Foundation
import DBNetworkStack

struct UploadAccessServiceMock: MultipartFormDataUploadAccessProviding {
    func upload(request: NetworkRequestRepresening, relativeToBaseURL: NSURL, multipartFormData: (MultipartFormDataRepresenting) -> (), encodingMemoryThreshold: UInt64, callback: (NSData?, NSHTTPURLResponse?, NSError?) -> (), onNetworkTaskCreation: DBNetworkTaskCreationCompletionBlock?) {
        
        dispatch_async(dispatch_get_main_queue()) {
            onNetworkTaskCreation?(NetworkTaskMock())
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2.0)*Int64(NSEC_PER_SEC)), dispatch_get_main_queue(), {
                callback(NSData(),nil,nil)
            })
        }
        
    }
}