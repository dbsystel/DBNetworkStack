//
//  NetworkRequestTest.swift
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
//  Created by Lukas Schmidt on 20.09.16.
//

import Foundation
import XCTest
@testable import DBNetworkStack

class NetworkRequestTest: XCTestCase {
    
    static var allTests = {
        return [
            ("testURLRequestTranformation", testURLRequestTranformation)        ]
    }()
    
    func testURLRequestTranformation() {
        //Given
        let path = "/index.html"
        let baseURLKey = "Key"
        let httpMethod = HTTPMethod.GET
        let parameter: [String : Any] = ["test1": 1, "test2": "2"] as [String : Any]
        let body: Data! = "hallo body data".data(using: String.Encoding.utf8)
        let headerFields: Dictionary<String, String> = [:]
        let baseURL: URL! = URL(string: "https://www.bahn.de/")

        //When
        let request = NetworkRequest(path: path, baseURLKey: baseURLKey,
                                     HTTPMethod: httpMethod, parameter: parameter,
                                     body: body, allHTTPHeaderFields: headerFields)
        
        //Then
        let urlRequest = request.urlRequest(with: baseURL)
        
        let reuqestURL: URL! = urlRequest.url
        let query = URLComponents(url: reuqestURL, resolvingAgainstBaseURL: true)?.queryItems
        XCTAssertEqual(query?.count, 2)
        XCTAssert(query?.contains(where: { $0.name == "test1" && $0.value == "1" }) ?? false)
        XCTAssert(query?.contains(where: { $0.name == "test2" && $0.value == "2" }) ?? false)
        XCTAssertEqual(urlRequest.httpMethod, httpMethod.rawValue)
        XCTAssertEqual(urlRequest.httpBody, body)
        XCTAssertEqual(urlRequest.allHTTPHeaderFields ?? [:], headerFields)
    }
    
    func testAssertOnPathebeginsWith() {
        var hasError = false
        let errorColusre: (String, StaticString, UInt) -> Void = { message, file, line in
            hasError = true
        }
        //Given
        let path = "/trains"
        
        //When
        _ = NetworkRequest(path: path, baseURLKey: "", onIllegalArguments: errorColusre)
        
        //Then
        XCTAssert(hasError)
    }
}
