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
//  ModifyRequestNetworkService.swift
//  DBNetworkStack
//
//  Created by Lukas Schmidt on 16.12.16.
//

import XCTest
import Foundation
@testable import DBNetworkStack

class ModifyRequestNetworkServiceTest: XCTestCase {
    
    let url: URL! = URL(string: "bahn.de")
    var networkServiceMock: NetworkServiceMock!
    
    override func setUp() {
        super.setUp()
        networkServiceMock = NetworkServiceMock()
    }
    
    func testRequest_withModifedRequest() {
        //Given
        let modification: Array<(URLRequestConvertible) -> URLRequestConvertible> = [ { request in
            return request.added(parameter: ["key": "1"])
            } ]
        let networkService: NetworkServiceProviding = ModifyRequestNetworkService(networkService: networkServiceMock, requestModifications: modification)
        let request = URLRequest(path: "/trains", baseURL: url)
        let ressource = Resource<Int>(request: request, parse: { _ in return 1 })
        
        //When
        networkService.request(ressource, onCompletion: { _ in }, onError: { _ in })
        
        //Then
        XCTAssert(networkServiceMock.lastRequest?.asURLRequest().url?.absoluteString.contains("key=1") ?? false)
    }
    
    func testAddHTTPHeaderToRequest() {
        //Given
        let request = URLRequest(url: url)
        let header = ["header": "head"]
        
        //When
        let newRequest = request.added(HTTPHeaderFields: header).asURLRequest()
        
        //Then
        XCTAssertEqual(newRequest.allHTTPHeaderFields?["header"], "head")
    }
}
