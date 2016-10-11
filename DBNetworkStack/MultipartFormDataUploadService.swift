//
//  MultipartFormDataUploadService.swift
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
//
//  DBNetworkStack
//

import Foundation

public final class MultipartFormDataUploadService: MultipartFormDataUploadServiceProviding, NetworkResponseProcessing, BaseURLProviding {
    
    private let uploadAccess: MultipartFormDataUploadAccessProviding
    let endPoints: Dictionary<String, NSURL>
    
    /**
     Creates an `MultipartFormDataUploadService` instance with a given uploadAccess and a map of endPoints
     
     - parameter uploadAccess: provides basic access to the network.
     - parameter endPoints: map of baseURLKey -> baseURLs
     */
    public init(uploadAccess: MultipartFormDataUploadAccessProviding, endPoints: Dictionary<String, NSURL>) {
        self.uploadAccess = uploadAccess
        self.endPoints = endPoints
    }
    
    
    public func upload<T: MultipartFormDataRessourceModelling>(ressource: T, onCompletion: (T.Model) -> (), onError: (DBNetworkStackError) -> (), onNetworkTaskCreation: DBNetworkTaskCreationCompletionBlock? = nil) {
        
        let baseURL = self.baseURL(with: ressource)
        uploadAccess.upload(ressource.request, relativeToBaseURL: baseURL, multipartFormData: ressource.encodeInMultipartFormData, encodingMemoryThreshold: ressource.encodingMemoryThreshold, callback: { data, response, error in
            self.processAsync(response: response, ressource: ressource, data: data, error: error, onCompletion: onCompletion, onError: onError)
                
        }, onNetworkTaskCreation: { task in
            dispatch_async(dispatch_get_main_queue(), {
                onNetworkTaskCreation?(task)
            })
        })
    }
}
