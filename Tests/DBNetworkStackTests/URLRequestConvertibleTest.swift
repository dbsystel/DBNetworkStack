//
//  Copyright (C) 2017 DB Systel GmbH.
//  DB Systel GmbH; Jürgen-Ponto-Platz 1; D-60329 Frankfurt am Main; Germany; http://www.dbsystel.de/
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

import Foundation
import XCTest
@testable import DBNetworkStack

class URLRequestConvertibleTest: XCTestCase {
   
    func test_should_compile() {
        //Given
        let url: URL! = URL(string: "http://bahn.de")
        
        //When
        _ = URLRequest(url: url) as URLRequestConvertible
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
    
    func testDeprecatedCustomInitializer() {
        //Given
        let path = "train"
        let url: URL! = URL(string: "http://bahn.de")
        let parameters: [String: String] = ["query": "2", "test": "true"]
        let body: Data! = "Hallo".data(using: .utf8)
        let httpHeaderFields = ["header": "HeaderValue"]
        
        //When
        let request = URLRequest(path: path, baseURL: url, HTTPMethod: .DELETE, parameters: parameters, body: body, allHTTPHeaderFields: httpHeaderFields)
        
        //Then
        let reuqestURL: URL! = request.url
        let query = URLComponents(url: reuqestURL, resolvingAgainstBaseURL: true)?.queryItems
        XCTAssertEqual(query?.count, 2)
        XCTAssert(query?.contains(where: { $0.name == "test" && $0.value == "true" }) ?? false)
        XCTAssert(query?.contains(where: { $0.name == "query" && $0.value == "2" }) ?? false)
        
        XCTAssertEqual(request.httpBody, body)
        XCTAssertEqual(request.allHTTPHeaderFields?["header"], "HeaderValue")
    }
    
    func testCustomInitializer() {
        //Given
        let path = "train"
        let url: URL! = URL(string: "http://bahn.de")
        let parameters = ["query": "2", "test": "true"]
        let body: Data! = "Hallo".data(using: .utf8)
        let httpHeaderFields = ["header": "HeaderValue"]
        
        //When
        let request = URLRequest(path: path, baseURL: url, HTTPMethod: .DELETE, parameters: parameters, body: body, allHTTPHeaderFields: httpHeaderFields)
        
        //Then
        let reuqestURL: URL! = request.url
        let query = URLComponents(url: reuqestURL, resolvingAgainstBaseURL: true)?.queryItems
        XCTAssertEqual(query?.count, 2)
        XCTAssert(query?.contains(where: { $0.name == "test" && $0.value == "true" }) ?? false)
        XCTAssert(query?.contains(where: { $0.name == "query" && $0.value == "2" }) ?? false)

        XCTAssertEqual(request.httpBody, body)
        XCTAssertEqual(request.allHTTPHeaderFields?["header"], "HeaderValue")
    }
    
    func testURLWithQueryParameter() {
        //Given
        let url: URL! = URL(string: "http://bahn.de/train")
        let parameters = ["query": "2", "test": "true"]
        
        //When
        let urlWithParameter = url.replacingAllQueryParameters(with: parameters)
        
        //Then
        let query = URLComponents(url: urlWithParameter, resolvingAgainstBaseURL: true)?.queryItems
        XCTAssertEqual(query?.count, 2)
        XCTAssert(query?.contains(where: { $0.name == "test" && $0.value == "true" }) ?? false)
        XCTAssert(query?.contains(where: { $0.name == "query" && $0.value == "2" }) ?? false)
    }

}
