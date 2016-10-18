//
//  MultipartFormDataUploadService.swift
//
//  Copyright (C) 2016 DB Systel GmbH.
//	DB Systel GmbH; Jürgen-Ponto-Platz 1; D-60329 Frankfurt am Main; Germany; http://www.dbsystel.de/
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
//  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//
//  Created by Christian Himmelsbach on 29.09.16.
//


import Foundation

public final class MultipartFormDataUploadService: MultipartFormDataUploadServiceProviding, NetworkResponseProcessing, BaseURLProviding {
    
    fileprivate let uploadAccess: MultipartFormDataUploadAccessProviding
    let endPoints: Dictionary<String, URL>
    
    /**
     Creates an `MultipartFormDataUploadService` instance with a given uploadAccess and a map of endPoints
     
     - parameter uploadAccess: provides basic access to the network.
     - parameter endPoints: map of baseURLKey -> baseURLs
     */
    public init(uploadAccess: MultipartFormDataUploadAccessProviding, endPoints: Dictionary<String, URL>) {
        self.uploadAccess = uploadAccess
        self.endPoints = endPoints
    }
    
    public func upload<T: MultipartFormDataRessourceModelling>(_ ressource: T, onCompletion: @escaping (T.Model) -> (),
                       onError: @escaping (DBNetworkStackError) -> (), onNetworkTaskCreation: DBNetworkTaskCreationCompletionBlock? = nil) {
        
        let baseURL = self.baseURL(with: ressource)
        uploadAccess.upload(ressource.request, relativeToBaseURL: baseURL, multipartFormData: ressource.encodeInMultipartFormData,
                            encodingMemoryThreshold: ressource.encodingMemoryThreshold, callback: { data, response, error in
            self.processAsyncResponse(response: response, ressource: ressource, data: data, error: error, onCompletion: onCompletion, onError: onError)
                
        }, onNetworkTaskCreation: { task in
            DispatchQueue.main.async(execute: {
                onNetworkTaskCreation?(task)
            })
        })
    }
}
