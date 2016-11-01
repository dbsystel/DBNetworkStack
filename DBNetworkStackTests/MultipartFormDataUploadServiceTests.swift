//
//  MultipartFormDataUploadServiceTests.swift
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
//  Created by Christian Himmelsbach on 29.09.16.
//

import XCTest
@testable import DBNetworkStack

class MultipartFormDataUploadServiceTests: XCTestCase {

    var networkAccess = UploadAccessServiceMock()
    var service: MultipartFormDataUploadServiceProviding!
    
    override func setUp() {
        super.setUp()
        let url: URL! = URL(string: "http://bahn.de")
        service = MultipartFormDataUploadService(
            uploadAccess: networkAccess,
            endPoints: [ TestEndPoints.endPoint.name: url]
        )
    }

    func testUpload() {
        //Given
        let request = NetworkRequest(path: "/train", baseURLKey: TestEndPoints.endPoint)
        let resource = MultipartFormDataResource(request: request, parse: { $0 },
                                                   encodingMemoryThreshold: 200, encodeInMultipartFormData: {
            formdata in
        })
        networkAccess.changeMock(data: Train.validJSONData, response: nil, error: nil)
        var didCreateTask = false
        //When
        let expection = expectation(description: "loadValidRequest")
        service.upload(resource, onCompletion: { data in
            XCTAssertEqual(Train.validJSONData, data)
            XCTAssert(didCreateTask)
            expection.fulfill()
            }, onError: { err in
                print(err)
                XCTFail()
            }, onNetworkTaskCreation: { task in
                didCreateTask = true
            })
        waitForExpectations(timeout: 5, handler: nil)
    }

}
