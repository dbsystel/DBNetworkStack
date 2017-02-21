
//
//  Copyright (C) 2017 Lukas Schmidt.
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
//  File.swift
//  DBNetworkStack
//
//  Created by Lukas Schmidt on 21.02.17.
//

import Foundation
import XCTest
@testable import DBNetworkStack

class URLRequestConvertibleTest: XCTestCase {
   
    func test_should_compile() {
        //Given
        let url: URL! = URL(string: "http://bahn.de")
        
        //When
        let _: URLRequestConvertible = URLRequest(url: url)
    }
    
    func testConvertToRequest() {
        //Given
        let url: URL! = URL(string: "http://bahn.de")
        let request = URLRequest(url: url)
        
        //When
        let convertedRequest = request.asURLRequest()
        
        //Then
        XCTAssertEqual(request, convertedRequest)
    }
    
    func testCoustomInitializer() {
        //Given
        let path = "train"
        let url: URL! = URL(string: "http://bahn.de")
        let parameters: [String: Any] = ["query": 2, "test": true]
        let body: Data! = "Hallo".data(using: .utf8)
        let httpHeaderFields = ["header": "HeaderValue"]
        
        //When
        let request = URLRequest(path: path, baseURL: url, HTTPMethod: .DELETE, parameters: parameters, body: body, allHTTPHeaderFields: httpHeaderFields)
        
        //Then
        XCTAssertEqual(request.url?.absoluteString, "http://bahn.de/train?test=true&query=2")
        XCTAssertEqual(request.httpBody, body)
        XCTAssertEqual(request.allHTTPHeaderFields?["header"], "HeaderValue")
    }
    
    func testURLWithQueryParameter() {
        //Given
        let url: URL! = URL(string: "http://bahn.de")
        let parameters: [String: Any] = ["query": 2, "test": true]
        
        //When
        let urlWithParameter = url.appendingURLQueryParameter(parameters)
        
        //Then
        XCTAssertEqual(urlWithParameter.absoluteString, "http://bahn.de/train?test=true&query=2")
    }
}
