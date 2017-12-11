//
//  Copyright (C) 2017 DB Systel GmbH.
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

import XCTest
import DBNetworkStack

class URLSessionNetworkAccessProvidingTest: XCTestCase {
    
    var urlSessionMock: URLSessionMock!
    
    override func setUp() {
        urlSessionMock = URLSessionMock()
    }
    
    func testCorrectArgumentsGetPassedToURLSession() {
        //Given
        let request = URLRequest.defaultMock
        
        //When
        _ = urlSessionMock.load(request: request, callback: { _, _, _ in })
        
        //Then
        XCTAssertEqual(urlSessionMock.lastOutgoingRequest, request)
    }
    
    func testDataTaskGetsResumed() {
        //Given
        let request = URLRequest.defaultMock
        
        //When
        _ = urlSessionMock.load(request: request, callback: { _, _, _ in })
        
        //Then
        XCTAssertTrue(urlSessionMock.currentDataTask.didResume)
    }
    
    func testCompleteWithResult() {
        //Given
        let data = Data()
        let reponse = HTTPURLResponse(url: .defaultMock, statusCode: 0, httpVersion: nil, headerFields: nil)
        let error = NSError(domain: "", code: 0, userInfo: nil)
        
        var capturedData: Data?
        var capturedResponse: HTTPURLResponse?
        var capturedError: Error?
        
        //When
        _ = urlSessionMock.load(request: .defaultMock, callback: { data, response, error in
            capturedData = data
            capturedResponse = response
            capturedError = error
        })
        urlSessionMock.completeWith(data: data, response: reponse, error: error)
        
        //Then
        XCTAssertEqual(data, capturedData)
        XCTAssertEqual(reponse, capturedResponse)
        XCTAssertNotNil(capturedError)
    }
}
