//
//  NetworkServiceTest.swift
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
//  Created by Lukas Schmidt on 26.07.16.
//

import XCTest
@testable import DBNetworkStack
import Alamofire

enum TestEndPoints: BaseURLKey {
    case EndPoint
    
    var name: String {
        return "endPointTestKey"
    }
}

class NetworkServiceTest: XCTestCase {
    var networkService: NetworkServiceProviding!
    
    var networkAccess = NetworkAccessMock()
    let trainName: NSString = "ICE"
    
    let baseURL =  NSURL(string: "//bahn.de")!
    
    override func setUp() {
        networkService = NetworkService(networkAccess: networkAccess, endPoints: ["endPointTestKey": baseURL])
    }
    
    func testValidRequest() {
        //Given
        let request = NetworkRequest(path:"/train", baseURLKey: TestEndPoints.EndPoint)
        let ressource = JSONRessource<Train>(request: request)
        networkAccess.changeMock(data: Train.validJSONData, response: nil, error: nil)
        
        //When
        var train: Train?
        networkService.fetch(ressource, onCompletion: { fetchedTrain in
            train = fetchedTrain
            }, onError: { err in
                XCTFail()
        })
        
        //Then
        XCTAssertEqual(train?.name, trainName)
        XCTAssertEqual(networkAccess.baseURL, baseURL)
    }

    func testNoData() {
        //Given
        let request = NetworkRequest(path:"/train", baseURLKey: TestEndPoints.EndPoint)
        let ressource = JSONRessource<Train>(request: request)
        networkAccess.changeMock(data: nil, response: nil, error: nil)
        
        
        //When
        var error: NSError?
        networkService.fetch(ressource, onCompletion: { fetchedTrain in
            XCTFail()
            }, onError: { err in
                error = err
        })
        //Then
        XCTAssertNotNil(error)
    }
    
    func testInvalidData() {
        //Given
        let request = NetworkRequest(path:"/train", baseURLKey: TestEndPoints.EndPoint)
        let ressource = JSONRessource<Train>(request: request)
        networkAccess.changeMock(data: Train.invalidJSONData, response: nil, error: nil)
        
        
        //When
        var error: NSError?
        networkService.fetch(ressource, onCompletion: { fetchedTrain in
            XCTFail()
            }, onError: { err in
                error = err
        })
        //Then
        XCTAssertNotNil(error)
    }
    
//
//    func testOnError() {
//        //Given
//        let returnedRequest = NetworkRequestMock(data: nil, error: NSError(domain: "", code: 0, userInfo: nil))
//        let alamofireMock = AlamofireMock(returnedRequest: returnedRequest)
//        let networkService = AlamofireNetworkService(requestFunction: alamofireMock.request, endPoints: ["endPointTestKey": NSURL(string: "//bahn.de")!])
//        
//        let request = NetworkRequest(path:"", baseURLKey: TestEndPoints.EndPoint, HTTPMethod: .GET)
//        let ressource = Ressource(request: request) { Train(name: NSString(data: $0, encoding: NSUTF8StringEncoding) as! String) }
//        var error: NSError?
//        
//        //When
//        networkService.fetch(ressource, onCompletion: { fetchedTrain in
//            }, onError: { err in
//                error = err
//        })
//        
//        //Then
//        XCTAssertNotNil(error)
//    }
}
