//
//  MultipartFormDataUploadAccessProviding.swift
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
//  Created by Christian Himmelsbach on 27.09.16.
//

import Foundation

/**
 `MultipartFormDataUploadAccessProviding` provides access to the network for multipart formdata Requests.
 */
protocol MultipartFormDataUploadAccessProviding {
    
    /**
     Uploads a multipart formdata resource asynchrony to remote location.
     
     - parameter request: The resource to upload.
     - parameter relativeToBaseURL: The base URL on wich the request is based on
     - parameter multipartFormData: Closure which configures the multipart form data body
     - parameter encodingMemoryThreshold: Encoding threshold in bytes.
     - parameter callback: Callback which gets called when the request finishes.
     - parameter onNetworkTaskCreation: Callback which gets called, after encoding data and starting the upload.
     The closure gets access to the created network task.
     
     */
    func upload(
        _ request: NetworkRequestRepresening,
        relativeToBaseURL baseURL: URL,
                          multipartFormData: @escaping (MultipartFormDataRepresenting) -> (),
                          encodingMemoryThreshold: UInt64,
                          callback: @escaping (Data?, HTTPURLResponse?, Error?) -> (),
                          onNetworkTaskCreation: @escaping (NetworkTaskRepresenting) -> ()
    )
}
