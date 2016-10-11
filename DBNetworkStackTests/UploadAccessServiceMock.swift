//
//  UploadAccessServiceMock.swift
//  DBNetworkStack
//
//	Legal Notice! DB Systel GmbH proprietary License!
//
//	Copyright (C) 2015 DB Systel GmbH
//	DB Systel GmbH; Jürgen-Ponto-Platz 1; D-60329 Frankfurt am Main; Germany; http://www.dbsystel.de/

//	This code is protected by copyright law and is the exclusive property of
//	DB Systel GmbH; Jürgen-Ponto-Platz 1; D-60329 Frankfurt am Main; Germany; http://www.dbsystel.de/

//	Consent to use ("licence") shall be granted solely on the basis of a
//	written licence agreement signed by the customer and DB Systel GmbH. Any
//	other use, in particular copying, redistribution, publication or
//	modification of this code without written permission of DB Systel GmbH is
//	expressly prohibited.

//	In the event of any permitted copying, redistribution or publication of
//	this code, no changes in or deletion of author attribution, trademark
//	legend or copyright notice shall be made.
//
//  Created by Christian Himmelsbach on 29.09.16.
//

import Foundation
import DBNetworkStack

class UploadAccessServiceMock: MultipartFormDataUploadAccessProviding {
    
    var uploadData: NSData?
    
    private var reponseData: NSData?
    private var responseError: NSError?
    private var response: NSHTTPURLResponse?
    private var multipartFormData: ((MultipartFormDataRepresenting) -> ())?
    
    func upload(request: NetworkRequestRepresening, relativeToBaseURL: NSURL, multipartFormData: (MultipartFormDataRepresenting) -> (), encodingMemoryThreshold: UInt64, callback: (NSData?, NSHTTPURLResponse?, NSError?) -> (), onNetworkTaskCreation: DBNetworkTaskCreationCompletionBlock?) {
        
        dispatch_async(dispatch_get_main_queue()) {
            multipartFormData(MulitpartFormDataRepresentingMock())
            onNetworkTaskCreation?(NetworkTaskMock())
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2.0)*Int64(NSEC_PER_SEC)), dispatch_get_main_queue(), {
                callback(self.reponseData, self.response, self.responseError)
            })
        }
        
    }
    
    func changeMock(data data: NSData?, response: NSHTTPURLResponse?, error: NSError?) {
        self.reponseData = data
        self.response = response
        self.responseError = error
    }
}
