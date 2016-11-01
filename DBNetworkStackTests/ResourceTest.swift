//
//  ResourceTest.swift
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
//  Created by Lukas Schmidt on 01.09.16.
//

import XCTest
@testable import DBNetworkStack

class ResourceTest: XCTestCase {
    
    func testResource() {
        //Given
        let validData = "ICE".data(using: String.Encoding.utf8)!

        let request = NetworkRequest(path: "/train", baseURLKey: "")
        let resource = Resource<String?>(request: request, parse: { String(data: $0, encoding: String.Encoding.utf8) })
        
        //When
        let name = try? resource.parse(validData)
        
        //Then
        XCTAssertNotNil(name)
        XCTAssertEqual(name!!, "ICE")
    }
    
    func testResourceWithInvalidData() {
        //Given
        let validData = Data()
        let request = NetworkRequest(path: "/train", baseURLKey: "")
        let resource = JSONResource<Train>(request: request)
        
        //When
        do {
            let _ = try resource.parse(validData)
            XCTFail()
        } catch { }
    }
}
