//
//  UploadAccessServiceMock.swift
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
@testable import DBNetworkStack

//class UploadAccessServiceMock: MultipartFormDataUploadAccessProviding {
//    
//    var uploadData: Data?
//    
//    fileprivate var reponseData: Data?
//    fileprivate var responseError: NSError?
//    fileprivate var response: HTTPURLResponse?
//    fileprivate var multipartFormData: ((MultipartFormDataRepresenting) -> Void)?
//    
//    func upload(_ request: NetworkRequestRepresening, relativeToBaseURL baseURL: URL, multipartFormData: @escaping (MultipartFormDataRepresenting) -> Void,
//                encodingMemoryThreshold: UInt64, callback: @escaping (Data?, HTTPURLResponse?, Error?) -> Void,
//                onNetworkTaskCreation: @escaping (NetworkTaskRepresenting) -> Void) {
//        DispatchQueue.main.async {
//            multipartFormData(MulitpartFormDataRepresentingMock())
//            onNetworkTaskCreation(NetworkTaskMock())
//            
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(2.0)*Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: {
//                callback(self.reponseData, self.response, self.responseError)
//            })
//        }
//    }
//        
//    func changeMock(data: Data?, response: HTTPURLResponse?, error: NSError?) {
//        self.reponseData = data
//        self.response = response
//        self.responseError = error
//    }
//}
