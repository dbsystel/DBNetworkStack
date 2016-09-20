//
//  NetworkRequestTest.swift
//  DBNetworkStack
//
//  Created by Lukas Schmidt on 20.09.16.
//  Copyright © 2016 DBSystel. All rights reserved.
//

import XCTest
@testable import DBNetworkStack

class NetworkRequestTest: XCTestCase {
    
    func testURLRequestTranformation() {
        //Given
        let path = "/index.html"
        let baseURLKey = "Key"
        let httpMethod = HTTPMethod.GET
        let parameter = ["test1": 1, "test2": "2"]
        let body = "hallo body data".dataUsingEncoding(NSUTF8StringEncoding)!
        let headerFields: Dictionary<String, String> = [:]
        let baseURL = NSURL(string: "https://www.bahn.de/")!
        
        //When
        let request = NetworkRequest(path: path, baseURLKey: baseURLKey, HTTPMethod: httpMethod, parameter: parameter, body: body, allHTTPHeaderFields: headerFields)
        
        //Then
        let urlRequest = request.urlRequest(with: baseURL)
        
        XCTAssertEqual(urlRequest.URL?.absoluteString, "https://www.bahn.de/index.html?test2=2&test1=1")
        XCTAssertEqual(urlRequest.HTTPMethod, httpMethod.rawValue)
        XCTAssertEqual(urlRequest.HTTPBody, body)
        XCTAssertEqual(urlRequest.allHTTPHeaderFields!, headerFields)
    }
}
