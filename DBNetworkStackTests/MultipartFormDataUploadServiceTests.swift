//
//  MultipartFormDataUploadServiceTests.swift
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
//  Created by Christian Himmelsbach on 29.09.16.
//

import XCTest
@testable import DBNetworkStack

class MultipartFormDataUploadServiceTests: XCTestCase {

    var networkAccess = UploadAccessServiceMock()
    var service: MultipartFormDataUploadServiceProviding!
    
    override func setUp() {
        super.setUp()
        service = MultipartFormDataUploadService(
            uploadAccess: networkAccess,
            endPoints: [ TestEndPoints.EndPoint.name: NSURL()]
        )
    }

    func testUpload() {
        //Given
        let request = NetworkRequest(path: "/train", baseURLKey: TestEndPoints.EndPoint)
        let ressource = MultipartFormDataRessource(request: request, parse: { $0 },
                                                   encodingMemoryThreshold: 200, encodeInMultipartFormData: {
            formdata in
        })
        networkAccess.changeMock(data: Train.validJSONData, response: nil, error: nil)
        var didCreateTask = false
        //When
        let expection = expectationWithDescription("loadValidRequest")
        service.upload(ressource, onCompletion: { data in
            XCTAssertEqual(Train.validJSONData, data)
            XCTAssert(didCreateTask)
            expection.fulfill()
            }, onError: { err in
                print(err)
                XCTFail()
            }, onNetworkTaskCreation: { task in
                didCreateTask = true
            })
        waitForExpectationsWithTimeout(5, handler: nil)
    }

}
