//
//  NetworkRequestTest.swift
//  DBNetworkStack
//
//	Legal Notice! DB Systel GmbH proprietary License!
//
//	Copyright (C) 2015 DB Systel GmbH
//	DB Systel GmbH; Jürgen-Ponto-Platz 1; D-60329 Frankfurt am Main; Germany; http://www.dbsystel.de/

//	This code is protected by copyright law and is the exclusive property of
//	DB Systel GmbH; Jürgen-Ponto-Platz 1; D-60329 Frankfurt am Main; Germany; http://www.dbsystel.de/

//	Consent to use ("licence") shall be granted solely on the basis of a
//	written licence agreement signed by the customer and DB Systel GmbH. Any
//	other use, in particular copying, redistribution, publication or
//	modification of this code without written permission of DB Systel GmbH is
//	expressly prohibited.

//	In the event of any permitted copying, redistribution or publication of
//	this code, no changes in or deletion of author attribution, trademark
//	legend or copyright notice shall be made.
//
//  Created by Lukas Schmidt on 20.09.16.
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
