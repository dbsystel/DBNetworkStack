//
//  Copyright (C) 2016 Lukas Schmidt.
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
//
//  NetworkServiceMock.swift
//  DBNetworkStack
//
//  Created by Lukas Schmidt on 14.12.16.
//

import Foundation
import DBNetworkStack

class NetworkServiceMock: NetworkServiceProviding {
    private var onErrorCallback: ((DBNetworkStackError) -> Void)?
    private var onSuccess: (() -> Void)?
    
    var requestCount: Int = 0

    func request<T: ResourceModeling>(_ resource: T, onCompletion: @escaping (T.Model) -> Void,
                 onError: @escaping (DBNetworkStackError) -> Void) -> NetworkTaskRepresenting {
        onSuccess = {
             onCompletion(try! resource.parse(Data()))
        }
        onErrorCallback = { error in
            onError(error)
        }
        
        return NetworkTaskMock()
    }
    
    func returnError(error: DBNetworkStackError, count: Int = 1) {
        for _ in 0...count {
            onErrorCallback?(error)
        }
        onErrorCallback = nil
    }
    
    func returnSuccess(count: Int = 1) {
        for _ in 0...count {
            onSuccess?()
        }
        onSuccess = nil
    }
}
