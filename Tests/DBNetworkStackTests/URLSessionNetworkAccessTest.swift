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

class URLSessionProtocolMock: URLSessionProtocol {
    var request: URLRequest?
    var callback: ((Data?, URLResponse?, Error?) -> Void)?

    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        self.request = request
        self.callback = completionHandler
        
        let url: URL! = URL(string: "http://bahn.de")
        return URLSession(configuration: .default).dataTask(with: url)
    }
}

class URLSessionNetworkAccessTest: XCTestCase {
    
    func testURLSession_MatchesTypeOfNetworkAccess() {
        let _: NetworkAccessProviding = URLSession(configuration: .default)
    }
    
    func test_URLSessionCreatsDataTask() {
        //Given
        let mock = URLSessionProtocolMock()
        let url: URL! = URL(string: "http://bahn.de")
        let urlRequest = URLRequest(url: url)
        
        //When
        _ = mock.load(request: urlRequest, callback: { _, _, _ in
        
        })
        
        //Then
        XCTAssertNotNil(mock.request)
        XCTAssertEqual(urlRequest, mock.request)
    }
    
    func testURLSession_CallbackGetsRegistered() {
        //Given
        let mock = URLSessionProtocolMock()
        let url: URL! = URL(string: "http://bahn.de")
        let urlRequest = URLRequest(url: url)
        var completionHanlderCalled = false
        //When
        _ = mock.load(request: urlRequest, callback: { _, _, _ in
            completionHanlderCalled = true
        })
        mock.callback?(nil, nil, nil)
        
        //Then
        XCTAssert(completionHanlderCalled)
    }
    
    func testURLSession_DataTaksGetsResumed() {
        //Given
        let mock = URLSessionProtocolMock()
        let url: URL! = URL(string: "http://bahn.de")
        let urlRequest = URLRequest(url: url)
        
        //When
        let task = mock.load(request: urlRequest, callback: { _, _, _ in
        })
        
        //Then
        guard let sessionTask = task as? URLSessionDataTask else {
            XCTFail()
            return
        }
        XCTAssert(sessionTask.state == .running)
    }
}
