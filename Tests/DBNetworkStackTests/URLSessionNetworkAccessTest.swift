//
//  URLSessionNetworkAccessTest.swift
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
//  Created by Lukas Schmidt on 13.09.16.
//

import Foundation
import XCTest
@testable import DBNetworkStack

class URLSessionNetworkAccessTest: XCTestCase {
    
    var urlSessionMock: URLSessionProtocolMock!
    let url: URL! = URL(string: "http://bahn.de")
    var urlRequest: URLRequest {
        return URLRequest(url: url)
    }
    
    override func setUp() {
        super.setUp()
        urlSessionMock = URLSessionProtocolMock()
    }
    
    override func tearDown() {
        urlSessionMock = nil
        super.tearDown()
    }
    
    func testURLSession_MatchesTypeOfNetworkAccess() {
        let _: NetworkAccessProviding = URLSession(configuration: .default)
    }
    
    func test_URLSessionCreatsDataTask() {
        //When
        _ = urlSessionMock.load(request: urlRequest, callback: { _, _, _ in })
        
        //Then
        XCTAssertNotNil(urlSessionMock.request)
        XCTAssertEqual(urlRequest, urlSessionMock.request)
    }
    
    func testURLSession_CallbackGetsRegistered() {
        //Given
        var completionHanlderCalled = false
        
        //When
        _ = urlSessionMock.load(request: urlRequest, callback: { _, _, _ in
            completionHanlderCalled = true
        })
        urlSessionMock.callback?(nil, nil, nil)
        
        //Then
        XCTAssert(completionHanlderCalled)
    }
    
    func testURLSession_DataTaksGetsResumed() {
        //When
        let task = urlSessionMock.load(request: urlRequest, callback: { _, _, _ in
        })
        
        //Then
        guard let sessionTask = task as? URLSessionDataTask else {
            XCTFail()
            return
        }
        XCTAssert(sessionTask.state == .running)
    }
}
