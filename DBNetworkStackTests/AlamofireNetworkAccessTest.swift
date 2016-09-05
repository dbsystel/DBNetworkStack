//
//  AlamofireNetworkAccessTest.swift
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
//  Created by Lukas Schmidt on 31.08.16.
//

import XCTest
@testable import DBNetworkStack


//class AlamofireNetworkAccessTest: XCTestCase {
//    
//    var alamofireMock = AlamofireMock()
//    var networkAccess: AlamofireNetworkAccessProvider!
//    
//    override func setUp() {
//        networkAccess = AlamofireNetworkAccessProvider(requestFunction: alamofireMock.request, endPoints: [TestEndPoints.EndPoint.name: NSURL()])
//    }
//    
//    func testValidRequest() {
//        //Given
//        let parameter: [String: AnyObject] = ["id": 1, "name": "ICE"]
//        let headers = ["testHeaderField": "testHeaderValue"]
//        let request = NetworkRequest(path:"/train", baseURLKey: TestEndPoints.EndPoint, HTTPMethod: .GET, parameter: parameter, allHTTPHeaderField: headers)
//        let baseURL = NSURL(string: "https://bahn.de")!
//        
//        //When
//        networkAccess.load(request: request, relativeToBaseURL: baseURL, callback: { _, _, _ in
//            
//        })
//        
//        //Then
//        XCTAssertEqual(alamofireMock.URLString?.URLString, "https://bahn.de/train")
//        XCTAssertEqual(alamofireMock.method, HTTPMethod.GET.alamofireMethod)
//        //XCTAssertEqual(alamofireMock.parameters, url.URLString)
//        
//        //XCTAssert(alamofireMock.encoding! == Alamofire.ParameterEncoding.URL)
//        XCTAssertEqual(alamofireMock.headers!, headers)
//        XCTAssertEqual(alamofireMock.parameter?.count, 2)
//        XCTAssertEqual(alamofireMock.parameter?["id"] as? Int, 1)
//        XCTAssertEqual(alamofireMock.parameter?["name"] as? String, "ICE")
//        
//    }
//}